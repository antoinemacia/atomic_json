# frozen_string_literal: true

require 'atomic_json/json_query_helpers'

module AtomicJson
  class QueryBuilder

    include JsonQueryHelpers

    attr_reader :record, :connection

    delegate :quote_column_name, :quote_table_name, :quote, to: :connection

    def initialize(record, connection)
      @record = record
      @connection = connection
    end

    def build(attributes, touch)
      <<~SQL
        UPDATE #{quote_table_name(record.class.table_name)}
        SET #{build_set_subquery(attributes, touch)}
        WHERE id = #{quote(record.id)};
      SQL
    end

    private

      def build_set_subquery(attributes, touch)
        updates = json_updates_agg(attributes)
        updates << timestamp_update_string if touch && record.has_attribute?(:updated_at)
        updates.join(',')
      end

      def json_updates_agg(attributes)
        attributes.map do |column, payload|
          "#{quote_column_name(column)} = #{json_deep_merge(column, payload)}"
        end
      end

      def timestamp_update_string
        "#{quote_column_name(:updated_at)} = #{quote(Time.now)}"
      end

      def json_deep_merge(target, payload)
        loop do
          keys, value = traverse_payload(Hash[*payload.shift])
          target = jsonb_set_query_string(target, keys, value)
          break target if payload.empty?
        end
      end

      ##
      # Traverse the Hash payload, incrementally
      # aggregating all hash keys into an array
      # and use the last child as value
      def traverse_payload(key_value_pair, keys = [])
        loop do
          key, val = key_value_pair.flatten
          keys << key.to_s
          break [keys, val] unless single_value_hash?(val)
          key_value_pair = val
        end
      end

      def jsonb_set_query_string(target, keys, value)
        <<~EOF
          jsonb_set(
            #{target}::jsonb,
            #{jsonb_quote_keys(keys)},
            #{multi_value_hash?(value) ? concatenation(target, keys, value) : jsonb_quote_value(value)}
          )::jsonb
        EOF
      end

      def multi_value_hash?(value)
        value.is_a?(Hash) && value.keys.count > 1
      end

      def single_value_hash?(value)
        value.is_a?(Hash) && value.keys.count == 1
      end
  end
end
