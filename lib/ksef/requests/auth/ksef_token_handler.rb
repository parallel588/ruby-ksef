# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for KSEF token authentication
      class KsefTokenHandler
        def initialize(http_client, ksef_token, identifier)
          @http_client = http_client
          @ksef_token = ksef_token
          @identifier = identifier
        end

        def call(challenge_response)
          # Get KSEF public key
          public_key_handler = Security::PublicKeyHandler.new(@http_client)
          public_keys = public_key_handler.call

          # Find KSeF token encryption certificate
          # Note: usage field is an array, not a string
          cert_data = public_keys.find do |k|
            usage = k["usage"]
            if usage.is_a?(Array)
              usage.include?("KsefTokenEncryption")
            else
              usage == "KsefTokenEncryption"
            end
          end
          raise Error, "KsefTokenEncryption certificate not found" unless cert_data

          # Decrypt certificate and get public key
          cert_der = Base64.decode64(cert_data["certificate"])
          certificate = OpenSSL::X509::Certificate.new(cert_der)
          public_key = certificate.public_key

          # Create payload: TOKEN|TIMESTAMP (timestamp must be in milliseconds!)
          timestamp_ms = challenge_response["timestampMs"] || challenge_response["timestamp"]
          payload = "#{@ksef_token.token}|#{timestamp_ms}"

          # Encrypt with RSA-OAEP using SHA-256 (required by KSeF API)
          encrypted_token = encrypt_with_oaep_sha256(public_key, payload)

          # Send authentication request
          body = {
            challenge:         challenge_response["challenge"],
            contextIdentifier: {
              type:  "Nip",
              value: @identifier.value
            },
            encryptedToken:    encrypted_token
          }

          response = @http_client.post("auth/ksef-token", body: body)
          response.json
        end

        private

        def encrypt_with_oaep_sha256(public_key, data)
          # Ruby 3.0+ supports explicit OAEP parameters
          encrypted = public_key.encrypt(
            data,
            {
              rsa_padding_mode: "oaep",
              rsa_oaep_md:      "sha256",
              rsa_mgf1_md:      "sha256"
            }
          )
          Base64.strict_encode64(encrypted)
        end
      end
    end
  end
end
