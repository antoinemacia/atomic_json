# frozen_string_literal: true
require 'active_support/core_ext/hash/reverse_merge'
require 'atomic_json/json_quote'

module AtomicJson
  class SingleUpdate < Query

    def build(attributes)
      self.query_string = build_query_string(
        *keys_and_value(attributes)
      )
      self
    end

    private

      def build_query_string(keys, value)
        <<~SQL
          UPDATE #{quote_table_name(record.class.table_name)}
          SET #{quote_column_name(jsonb_field)} = jsonb_set(
                #{quote_column_name(jsonb_field)},
                #{jsonb_quote_keys(keys)},
                #{jsonb_quote_value(value)},
                #{jsonb_quote_boolean(options[:create_missing])}
              )
          WHERE id = #{quote(record.id)};
        SQL
      end

      def keys_and_value(attributes)
        if options[:nested]
          nested_keys_value(attributes)
        else
          [[attributes.keys.first], attributes.values.first]
        end
      end

      ##
      # Traverse the attributes hash, aggregating all hash keys into an
      # array and keep the last value
      def nested_keys_value(attributes)
        keys = []

        val = loop do
          key, val = attributes.flatten
          keys << key.to_s
          break val unless val.is_a?(Hash)
          attributes = val
        end

        [keys, val]
      end

  end
end
