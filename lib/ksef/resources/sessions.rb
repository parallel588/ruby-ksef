# frozen_string_literal: true

module KSEF
  module Resources
    # Sessions resource for invoice operations
    class Sessions
      def initialize(http_client)
        @http_client = http_client
      end

      # List sessions
      def list(params)
        Requests::Sessions::ListHandler.new(@http_client).call(params)
      end

      # Send online invoice
      # @param reference_number [String] Session reference number
      # @param params [Hash] Invoice parameters
      # @return [Hash] Send response
      def send_online(reference_number, params)
        Requests::Sessions::SendOnlineHandler.new(@http_client).call(reference_number, params)
      end

      # Send batch invoices
      # @param params [Hash] Batch parameters with invoices array
      # @return [Hash] Batch send response
      def send_batch(params)
        Requests::Sessions::SendBatchHandler.new(@http_client).call(params)
      end

      # Check session status
      # @param reference_number [String] Session reference number
      # @return [Hash] Session status
      def status(reference_number)
        Requests::Sessions::StatusHandler.new(@http_client).call(reference_number)
      end

      # Terminate session
      # @param reference_number [String] Session reference number
      # @return [Hash] Terminate response
      def terminate(reference_number)
        Requests::Sessions::TerminateHandler.new(@http_client).call(reference_number)
      end

      # Download UPO by KSEF number
      # @param session_reference_number [String] Session reference number
      # @param ksef_number [String] KSEF invoice number
      # @return [Hash] UPO document
      def upo_by_ksef_number(session_reference_number, ksef_number)
        Requests::Sessions::UpoByKsefNumberHandler.new(@http_client).call(session_reference_number, ksef_number)
      end

      # Download UPO by invoice reference number
      # @param session_reference_number [String] Session reference number
      # @param invoice_reference_number [String] Invoice reference number
      # @return [Hash] UPO document
      def upo_by_invoice_reference(session_reference_number, invoice_reference_number)
        Requests::Sessions::UpoByInvoiceReferenceHandler.new(@http_client).call(session_reference_number,
                                                                                invoice_reference_number)
      end

      # Download UPO by UPO reference number
      # @param session_reference_number [String] Session reference number
      # @param upo_reference_number [String] UPO reference number
      # @return [Hash] UPO document
      def upo(session_reference_number, upo_reference_number)
        Requests::Sessions::UpoHandler.new(@http_client).call(session_reference_number, upo_reference_number)
      end

      # Close online session
      # @param session_reference_number [String] Session reference number
      # @return [Hash] Close response
      def close_online(session_reference_number)
        Requests::Sessions::CloseOnlineHandler.new(@http_client).call(session_reference_number)
      end

      # open online session
      # @return [Hash] Close response
      def open_online(invoice_schema, encryption_key)
        Requests::Sessions::OpenOnlineHandler.new(@http_client).call(invoice_schema, encryption_key)
      end
      
      # Close batch session
      # @param session_reference_number [String] Session reference number
      # @return [Hash] Close response
      def close_batch(session_reference_number)
        Requests::Sessions::CloseBatchHandler.new(@http_client).call(session_reference_number)
      end

      # List invoices in session
      # @param session_reference_number [String] Session reference number
      # @param params [Hash] Query parameters
      # @return [Hash] Invoices list
      def invoices(session_reference_number, params = {})
        Requests::Sessions::InvoicesHandler.new(@http_client).call(session_reference_number, params)
      end

      # Get invoice details in session
      # @param session_reference_number [String] Session reference number
      # @param invoice_reference_number [String] Invoice reference number
      # @return [Hash] Invoice details
      def invoice(session_reference_number, invoice_reference_number)
        Requests::Sessions::InvoiceHandler.new(@http_client).call(session_reference_number, invoice_reference_number)
      end

      # List failed invoices in session
      # @param session_reference_number [String] Session reference number
      # @param params [Hash] Query parameters
      # @return [Hash] Failed invoices list
      def failed_invoices(session_reference_number, params = {})
        Requests::Sessions::FailedInvoicesHandler.new(@http_client).call(session_reference_number, params)
      end
    end
  end
end
