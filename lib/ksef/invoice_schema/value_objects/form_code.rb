# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module ValueObjects
      # Kod formularza faktury
      class FormCode

        # POZOR: Hodnoty MUSÍ odpovídat fixed hodnotám v XSD!
        FA2 = "FA (2)"      # S MEZEROU! (podle XSD)
        FA3 = "FA (3)"      # S MEZEROU! (podle XSD)
        PEF = "PEF (3)"
        PEF_KOR = "PEF_KOR (3)"

        attr_reader :value

        def initialize(value = 3)  # Default FA(3) for KSeF 2.0 API
          # Accept integer or string
          @value = case value
                   when 2, "2", FA2, "FA(2)" then FA2  # Akceptuje i bez mezery pro BC
                   when 3, "3", FA3, "FA(3)" then FA3  # Akceptuje i bez mezery pro BC
                   when "PEF", PEF then PEF
                   when "PEF_KOR", PEF_KOR then PEF_KOR
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
          match = @value.match(/\((\d+)\)/)
          match ? match[1].to_i : 3
        end

        def target_namespace
          # Different namespaces for different form variants
          case @value
          when FA2
            "http://crd.gov.pl/wzor/2023/06/29/12648/"  # FA(2)
          when FA3
            "http://crd.gov.pl/wzor/2025/06/25/13775/"  # FA(3) - RC5.4
          when PEF, PEF_KOR
            "http://crd.gov.pl/wzor/2025/06/25/13775/"  # PEF uses FA(3) namespace
          else
            "http://crd.gov.pl/wzor/2025/06/25/13775/"  # Default to FA(3)
          end
        end

        private

        def validate!
          return if [FA2, FA3, PEF, PEF_KOR].include?(@value)

          raise ArgumentError, "Invalid form code: #{@value}. Valid codes: FA (2), FA (3), PEF (3), PEF_KOR (3)"
        end
      end
    end
  end
end
