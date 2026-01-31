# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for closing online session
      class OpenOnlineHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call()
          public_key_handler = Security::PublicKeyHandler.new(@http_client)
          public_keys = public_key_handler.call

          cert_data = public_keys.find do |k|
            usage = k["usage"]
            if usage.is_a?(Array)
              usage.include?('SymmetricKeyEncryption')
            else
              usage == "SymmetricKeyEncryption"
            end
          end
          raise Error, "SymmetricKeyEncryption certificate not found" unless cert_data

          # Decrypt certificate and get public key
          cert_der = Base64.decode64(cert_data["certificate"])
          certificate = OpenSSL::X509::Certificate.new(cert_der)
          public_key = certificate.public_key

          symmetric_key = SecureRandom.random_bytes(32)
          iv            = SecureRandom.random_bytes(16)

          encrypted_key = public_key.public_encrypt(
            symmetric_key,
            OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING
          )

          
          response = @http_client.post(
            "sessions/online",
            body: {
              "formCode": {
                "systemCode": "FA (3)",
                "schemaVersion": "1-0E",
                "value": "FA"
              },
              "encryption": {
                "encryptedSymmetricKey": Base64.strict_encode64(encrypted_key),
                "initializationVector":   Base64.strict_encode64(iv)
              }
            }
          )
          
          response.json
        end
      end
    end
  end
end
