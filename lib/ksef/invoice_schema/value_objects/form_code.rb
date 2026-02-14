# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module ValueObjects
      # Kod formularza faktury
      class FormCode
        FA2 = "FA (2)"
        FA3 = "FA (3)"

        attr_reader :value

        def initialize(value = 2)
          # Accept integer or string
          @value = case value
                   when 2, "2", FA2 then FA2
                   when 3, "3", FA3 then FA3
                   else value
                   end
          validate!
        end

        def to_s
          @value
        end

        def schema_version
          "1-0E" # Same version for all form codes
        end

        def wariant_formularza
          @value.match(/\((\d+)\)/)[1].to_i
        end

        def target_namespace
          "http://crd.gov.pl/wzor/2025/06/25/13775/"
        end

        private

        def validate!
          return if [FA2, FA3].include?(@value)

          raise ArgumentError, "Invalid form code: #{@value}"
        end
      end
    end
  end
end
