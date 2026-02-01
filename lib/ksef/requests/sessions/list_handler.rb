# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for closing online session
      class ListHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(params)
          response = @http_client.get("sessions", params: params)
          
          response.json
        end
      end
    end
  end
end
