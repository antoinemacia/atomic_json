# frozen_string_literal: true

module AtomicJson
  module JsonQueryHelpers

    def jsonb_quote_keys(keys)
      "'{#{keys.map(&:to_s).join(',')}}'"
    end

    def jsonb_quote_value(value)
      %('#{value.to_json}')
    end

    def concatenation(target, keys, value)
      "#{target}->#{keys.map { |x| quote(x) }.join('->')} || #{jsonb_quote_value(value)}"
    end

    def multiple_values?(value)
      value.is_a?(Hash) && value.keys.count > 1
    end

    def json_column_type?(record, column)
      record.type_for_attribute(column.to_s).type == :jsonb
    end

    def valid_payload_type?(payload)
      payload.is_a?(Hash)
    end

  end
end
