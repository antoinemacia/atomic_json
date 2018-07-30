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

    def build(attributes)
      self.query_string = <<~SQL
        UPDATE #{quote_table_name(record.class.table_name)}
        SET #{quote_column_name(jsonb_field)} = #{jsonb_data(attributes)}
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

      def jsonb_data(attributes, data = jsonb_field)
        loop do
          keys, value = traverse_nested_hash(Hash[*attributes.shift])
          data = jsonb_set_query_string(data, keys, value)
          break data if attributes.empty?
        end
      end

      ##
      # Traverse the attributes hash, aggregating all hash keys into an
      # array and use the last child as value
      def traverse_nested_hash(attributes)
        keys = []

        val = loop do
          key, val = attributes.flatten
          keys << key.to_s
          break val unless val.is_a?(Hash) && val.keys.count == 1
          attributes = val
        end

        [keys, val]
      end

      def jsonb_set_query_string(data, keys, value)
        <<~EOF
          jsonb_set(
            #{data},
            #{jsonb_quote_keys(keys)},
            #{value_by_update_type(keys, value)},
            #{options[:create_missing]}
          )::jsonb
        EOF
      end

      def value_by_update_type(keys, value)
        if multi_keys_update?(value)
          concatenation(jsonb_field, keys, value)
        else
          jsonb_quote_value(value)
        end
      end

  end
end
