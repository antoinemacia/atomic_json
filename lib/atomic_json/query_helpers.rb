# frozen_string_literal: true

module AtomicJson
  module QueryHelpers

    def jsonb_quote_keys(keys)
      "'{#{keys.map(&:to_s).join(',')}}'"
    end

    def jsonb_quote_value(value)
      %('#{value.to_json}')
    end

    def concatenation(jsonb_field, keys, value)
      "#{jsonb_field}->#{keys.map { |x| quote(x) }.join('->')} || #{jsonb_quote_value(value)}"
    end

    def multi_keys_update?(value)
      value.is_a?(Hash) && value.keys.count > 1
    end

  end
end
