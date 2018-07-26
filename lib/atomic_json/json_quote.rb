# frozen_string_literal: true

module AtomicJson
  module JsonQuote

    def jsonb_quote_keys(keys)
      "'{#{keys.map(&:to_s).join(',')}}'"
    end

    def jsonb_quote_value(value)
      %('#{value.to_json}')
    end

    def jsonb_quote_boolean(bool)
      bool
    end

  end
end
