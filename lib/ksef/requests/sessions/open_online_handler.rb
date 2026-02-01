# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for closing online session
      class OpenOnlineHandler
        # @doc """
        # Obsługiwane schematy:

        # SystemCode	SchemaVersion	Value
        # FA (2)	    1-0E	        FA
        # FA (3)	    1-0E	        FA
        # PEF (3)	    2-1	            PEF
        # PEF_KOR (3)	2-1	            PEF
        # """
        
        def initialize(http_client)
          @http_client = http_client
        end

        #   { "systemCode": "FA (3)", "schemaVersion": "1-0E", "value": "FA" }
        def call(invoice_schema, encryption_key)
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

          encryption = from_certificate_base64(encryption_key, cert_data["certificate"])
          
          response = @http_client.post(
            "sessions/online",
            body: {
              "formCode": invoice_schema,
              "encryption": encryption
            }
          )
          
          response.json
        end

        private

        
        def from_certificate_base64(encryption_key, certificate_base64)
          # Decrypt certificate and get public key
          cert_der = Base64.decode64(certificate_base64)
          certificate = OpenSSL::X509::Certificate.new(cert_der)
          public_key = certificate.public_key

          symmetric_key = encryption_key.key
          iv = encryption_key.iv

          encrypted_key = public_key.encrypt(
            symmetric_key,
            {
              rsa_padding_mode: "oaep",
              rsa_oaep_md:      "sha256",
              rsa_mgf1_md:      "sha256"
            }
          )
 
         {
           encryptedSymmetricKey: Base64.strict_encode64(encrypted_key),
           initializationVector:  Base64.strict_encode64(iv)
         }
       end

      end
    end
  end
end

