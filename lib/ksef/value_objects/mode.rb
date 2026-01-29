# frozen_string_literal: true

module KSEF
  module ValueObjects
    # Operating mode for KSEF API
    class Mode
      TEST_URL = "https://api-test.ksef.mf.gov.pl/api/v2"
      DEMO_URL = "https://ksef-demo.mf.gov.pl/api/v2"
      PRODUCTION_URL = "https://ksef.mf.gov.pl/api/v2"

      attr_reader :value

      def initialize(value)
        @value = normalize_value(value)
        validate!
      end

      def test?
        @value == :test
      end

      def demo?
        @value == :demo
      end

      def production?
        @value == :production
      end

      def default_url
        case @value
        when :test then TEST_URL
        when :demo then DEMO_URL
        when :production then PRODUCTION_URL
        end
      end

      def to_s
        @value.to_s
      end

      def ==(other)
        other.is_a?(self.class) && other.value == @value
      end

      alias eql? ==

      def hash
        @value.hash
      end

      private

      def normalize_value(value)
        case value
        when Symbol then value
        when String then value.downcase.to_sym
        else
          raise ValidationError, "Mode must be a Symbol or String"
        end
      end

      def validate!
        valid_modes = %i[test demo production]
        return if valid_modes.include?(@value)

        raise ValidationError, "Invalid mode: #{@value}. Must be one of: #{valid_modes.join(", ")}"
      end
    end
  end
end
