# frozen_string_literal: true

require 'atomic_json/query_helpers'

module AtomicJson
  class Query

    class QueryError < StandardError; end

    include AtomicJson::QueryHelpers

    ##
    # create_missing - create new key value if not exisiting, default to false
    # nested - Allow nested JSON update, default to true
    DEFAULT_OPTIONS = {
      create_missing: false,
      nested: true
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
      self.query_string = build_query_string(
        *keys_and_value(attributes)
      )
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

      def build_query_string(keys, value)
        <<~SQL
          UPDATE #{quote_table_name(record.class.table_name)}
          SET #{quote_column_name(jsonb_field)} = jsonb_set(
                #{quote_column_name(jsonb_field)},
                #{jsonb_quote_keys(keys)},
                #{value_by_update_type(keys, value)},
                #{options[:create_missing]}
              )
          WHERE id = #{quote(record.id)};
        SQL
      end

      def keys_and_value(attributes)
        if options[:nested]
          traverse_nested_hash(attributes)
        else
          [[attributes.keys.first], attributes.values.first]
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

      def value_by_update_type(keys, value)
        if multi_keys_update?(value)
          concatenation(jsonb_field, keys, value)
        else
          jsonb_quote_value(value)
        end
      end

  end
end
