# frozen_string_literal: true

require 'atomic_json/query_helpers'

module AtomicJson
  class Query

    class Error < StandardError; end

    include AtomicJson::QueryHelpers

    attr_reader :record, :column, :connection
    attr_accessor :query_string

    delegate :quote_column_name, :quote_table_name, :quote, to: :connection

    def initialize(record, column)
      @connection = ActiveRecord::Base.connection
      @column = column
      @record = record
    end

    def build(payload)
      self.query_string = <<~SQL
        UPDATE #{quote_table_name(record.class.table_name)}
        SET #{quote_column_name(column)} = #{jsonb_deep_merge(payload)}
        WHERE id = #{quote(record.id)};
      SQL
      self
    end

    def execute!
      connection.exec_update(query_string)
    rescue ActiveRecord::StatementInvalid => e
      raise Error, e.message
    end

    def to_s
      query_string
    end

    private

      def jsonb_deep_merge(payload, target = column)
        loop do
          keys, value = traverse_payload(Hash[*payload.shift])
          target = build_jsonb_set_query(target, keys, value)
          break target if payload.empty?
        end
      end

      ##
      # Traverse the Hash payload, incrementally
      # aggregating all hash keys into an array
      # and use the last child as value
      def traverse_payload(attributes)
        keys = []

        val = loop do
          key, val = attributes.flatten
          keys << key.to_s
          break val unless val.is_a?(Hash) && val.keys.count == 1
          attributes = val
        end

        [keys, val]
      end

      def build_jsonb_set_query(target, keys, value)
        <<~EOF
          jsonb_set(
            #{target}::jsonb,
            #{jsonb_quote_keys(keys)},
            #{value(keys, value)}
          )::jsonb
        EOF
      end

      def value(keys, value)
        if multiple_keys?(value)
          concatenation(column, keys, value)
        else
          jsonb_quote_value(value)
        end
      end

  end
end
