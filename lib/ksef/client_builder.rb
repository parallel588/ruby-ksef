# frozen_string_literal: true

module KSEF
  # Fluent builder for constructing KSEF client with auto-authentication
  #
  # @example Basic usage with certificate
  #   client = KSEF.build do
  #     mode :test
  #     certificate_path "/path/to/cert.p12", "passphrase"
  #     identifier "1234567890"
  #   end
  #
  # @example With existing tokens
  #   client = KSEF.build do
  #     mode :production
  #     access_token "your_token", expires_at: Time.now + 3600
  #     refresh_token "your_refresh_token"
  #   end
  class ClientBuilder
    attr_reader :config

    def initialize
      @config = Config.new
    end

    # Set operating mode
    # @param value [Symbol, String] :test, :demo, or :production
    def mode(value)
      @config = @config.with_mode(ValueObjects::Mode.new(value))
      self
    end

    # Set custom API URL
    # @param url [String] Base API URL
    def api_url(url)
      @config = @config.with_api_url(url)
      self
    end

    # Set access token
    # @param token [String] JWT access token
    # @param expires_at [Time, nil] Token expiration time
    def access_token(token, expires_at: nil)
      @config = @config.with_access_token(
        ValueObjects::AccessToken.new(token: token, expires_at: expires_at)
      )
      self
    end

    # Set refresh token
    # @param token [String] JWT refresh token
    # @param expires_at [Time, nil] Token expiration time
    def refresh_token(token, expires_at: nil)
      @config = @config.with_refresh_token(
        ValueObjects::RefreshToken.new(token: token, expires_at: expires_at)
      )
      self
    end

    # Set KSEF token for authentication
    # @param token [String] KSEF API token
    def ksef_token(token)
      @config = @config.with_ksef_token(
        ValueObjects::KsefToken.new(token)
      )
      self
    end

    # Set certificate path for authentication
    # @param path [String] Path to .p12 certificate
    # @param passphrase [String] Certificate passphrase
    def certificate_path(path, passphrase)
      @config = @config.with_certificate_path(
        ValueObjects::CertificatePath.new(path: path, passphrase: passphrase)
      )
      self
    end

    # Set encryption key for invoice encryption
    # @param key [String] AES-256 key (32 bytes)
    # @param iv [String] Initialization vector (16 bytes)
    def encryption_key(key, iv)
      @config = @config.with_encryption_key(
        ValueObjects::EncryptionKey.new(key: key, iv: iv)
      )
      self
    end

    # Generate random encryption key
    def random_encryption_key
      key = OpenSSL::Random.random_bytes(32)
      iv = OpenSSL::Random.random_bytes(16)
      encryption_key(key, iv)
    end

    # Set identifier (NIP) for authentication
    # @param value [String] Polish NIP (tax identification number)
    def identifier(value)
      @config = @config.with_identifier(
        ValueObjects::NIP.new(value)
      )
      self
    end

    # Set logger
    # @param logger [Logger] Logger instance
    def logger(logger)
      @config = @config.with_logger(logger)
      self
    end

    # Set max concurrent requests for async operations
    # @param value [Integer] Maximum concurrent requests (default: 8)
    def async_max_concurrency(value)
      @config = @config.with_async_max_concurrency(value)
      self
    end

    # Build and return configured client
    # @return [Resources::Client] Configured KSEF client
    def build
      # Create HTTP client
      http_client = HttpClient::Client.new(@config)

      # Handle encryption key if provided
      handle_encryption_key!(http_client) if @config.encryption_key

      # Auto-authenticate if needed
      auto_authenticate!(http_client) if should_authenticate?

      # Return configured client resource
      Resources::Client.new(http_client, @config)
    end

    private

    def should_authenticate?
      @config.access_token.nil? &&
        (@config.certificate_path || @config.ksef_token) &&
        @config.identifier
    end

    def auto_authenticate!(http_client)
      # Get challenge
      challenge_response = Requests::Auth::ChallengeHandler.new(http_client).call

      # Authenticate based on method
      auth_response = if @config.certificate_path
                        authenticate_with_certificate(http_client, challenge_response)
                      elsif @config.ksef_token
                        authenticate_with_ksef_token(http_client, challenge_response)
                      end

      # Set temporary auth token
      # Note: authenticationToken is a hash with "token" and "validUntil" keys
      temp_token = ValueObjects::AccessToken.new(
        token: auth_response["authenticationToken"]["token"],
        expires_at: nil
      )
      @config = @config.with_access_token(temp_token)
      http_client.config = @config

      # Wait for completion
      reference_number = auth_response["referenceNumber"]
      wait_for_auth_completion(http_client, reference_number)

      # Redeem tokens
      redeem_response = Requests::Auth::RedeemHandler.new(http_client).call

      # Set final tokens
      @config = @config
                .with_access_token(ValueObjects::AccessToken.from_hash(redeem_response["accessToken"]))
                .with_refresh_token(ValueObjects::RefreshToken.from_hash(redeem_response["refreshToken"]))

      http_client.config = @config
    end

    def authenticate_with_certificate(http_client, challenge_response)
      handler = Requests::Auth::XadesSignatureHandler.new(
        http_client,
        @config.certificate_path,
        @config.identifier
      )
      handler.call(challenge_response)
    end

    def authenticate_with_ksef_token(http_client, challenge_response)
      handler = Requests::Auth::KsefTokenHandler.new(
        http_client,
        @config.ksef_token,
        @config.identifier
      )
      handler.call(challenge_response)
    end

    def wait_for_auth_completion(http_client, reference_number)
      Support::Utility.retry(backoff: 10, retry_until: 120) do
        handler = Requests::Auth::StatusHandler.new(http_client)
        response = handler.call(reference_number)

        if response["status"]["code"] == 200
          response
        elsif response["status"]["code"] >= 400
          raise AuthenticationError, response["status"]["description"]
        else
          nil # Retry
        end
      end
    end

    def handle_encryption_key!(http_client)
      # Get KSEF public key
      handler = Requests::Security::PublicKeyHandler.new(http_client)
      public_keys = handler.call

      # Find symmetric key encryption certificate
      # Note: usage field is an array, not a string
      cert_data = public_keys.find do |k|
        usage = k["usage"]
        if usage.is_a?(Array)
          usage.include?("SymmetricKeyEncryption")
        else
          usage == "SymmetricKeyEncryption"
        end
      end
      raise Error, "SymmetricKeyEncryption certificate not found" unless cert_data

      # Convert DER to PEM and encrypt key
      cert_der = Base64.decode64(cert_data["certificate"])
      public_key = OpenSSL::X509::Certificate.new(cert_der).public_key

      # Encrypt encryption key with KSEF public key using RSA-OAEP with SHA-256
      key_to_encrypt = @config.encryption_key.key + @config.encryption_key.iv
      encrypted = public_key.encrypt(
        key_to_encrypt,
        {
          rsa_padding_mode: "oaep",
          rsa_oaep_md:      "sha256",
          rsa_mgf1_md:      "sha256"
        }
      )

      encrypted_key = ValueObjects::EncryptedKey.new(Base64.strict_encode64(encrypted))
      @config = @config.with_encrypted_key(encrypted_key)
    end
  end
end
