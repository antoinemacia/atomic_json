# frozen_string_literal: true

module AtomicJson
  module JsonQueryHelpers

    def jsonb_quote_keys(keys)
      "'{#{keys.map(&:to_s).join(',')}}'"
    end

    def jsonb_quote_value(value)
      %('#{value.to_json}')
    end

    def jsonb_quote_boolean(bool)
      bool
    end

    def update_via_concatenation(jsonb_field, keys, value)
      "#{jsonb_field}->#{keys.map { |x| quote(x) }.join('->')} || #{jsonb_quote_value(value)}"
    end

  end
end
