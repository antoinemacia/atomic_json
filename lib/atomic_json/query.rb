# frozen_string_literal: true

require 'atomic_json/query_helpers'

module AtomicJson
  class Query

    class QueryError < StandardError; end

    include AtomicJson::QueryHelpers

    ##
    # create_missing - create new key value if not exisiting, default to false
    DEFAULT_OPTIONS = {
      create_missing: false,
    }

    attr_reader :record, :jsonb_field, :connection, :options
    attr_accessor :query_string

    delegate :quote_column_name, :quote_table_name, :quote, to: :connection

    def initialize(record, jsonb_field, options = {})
      @connection = ActiveRecord::Base.connection
      @record = record
      @jsonb_field = jsonb_field
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def build(payload)
      self.query_string = <<~SQL
        UPDATE #{quote_table_name(record.class.table_name)}
        SET #{quote_column_name(jsonb_field)} = #{jsonb_deep_merge(payload)}
        WHERE id = #{quote(record.id)};
      SQL
      self
    end

    def execute!
      connection.exec_update(query_string)
    rescue ActiveRecord::StatementInvalid => e
      raise QueryError, e.message
    end

    def to_s
      query_string
    end

    private

      def jsonb_deep_merge(payload)
        column = jsonb_field
        loop do
          keys, value = traverse_hash(Hash[*payload.shift])
          column = build_jsonb_set_query(column, keys, value)
          break column if payload.empty?
        end
      end

      ##
      # Traverse the attributes hash, incrementally
      # aggregating all hash keys into an array
      # and use the last child as value
      def traverse_hash(attributes)
        keys = []

        val = loop do
          key, val = attributes.flatten
          keys << key.to_s
          break val unless val.is_a?(Hash) && val.keys.count == 1
          attributes = val
        end

        [keys, val]
      end

      def build_jsonb_set_query(column, keys, value)
        <<~EOF
          jsonb_set(
            #{column}::jsonb,
            #{jsonb_quote_keys(keys)},
            #{value_by_update_type(keys, value)},
            #{options[:create_missing]}
          )::jsonb
        EOF
      end

      def value_by_update_type(keys, value)
        if multiple_keys?(value)
          concatenation(jsonb_field, keys, value)
        else
          jsonb_quote_value(value)
        end
      end

  end
end
