# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for opening online session
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

        # Open online session with encryption
        # @param params [Hash] Session parameters
        # @option params [String] :invoice_version Invoice version (e.g. "FA (3)")
        # @option params [Hash] :encryption_info Encryption details
        #   - :encrypted_key [String] Base64 encoded RSA-encrypted AES key
        #   - :init_vector [String] Base64 encoded IV
        # @return [Hash] Session reference number and validity
        def call(params)
          body = prepare_body(params)

          response = @http_client.post(
            "sessions/online",
            body: body,
            headers: { "Content-Type" => "application/json" }
          )

          response.json
        end

        private

        def prepare_body(params)
          {
            formCode: {
              systemCode: "FA (3)",
              schemaVersion: "1-0E",
              value: "FA"
            },
            encryption: {
              encryptedSymmetricKey: params[:encryption_info][:encrypted_key],
              initializationVector: params[:encryption_info][:init_vector]
            }
          }
        end
      end
    end
  end
end

