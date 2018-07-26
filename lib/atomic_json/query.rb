# frozen_string_literal: true
require 'active_support/core_ext/hash/reverse_merge'
require 'atomic_json/json_quote'

module AtomicJson
  class Query

    class QueryError < StandardError; end

    include AtomicJson::JsonQuote

    ##
    # create_missing - create new key value if not exisiting, default to false
    # nested - Allow nested JSON update, default to true
    DEFAULT_OPTIONS = {
      create_missing: false,
      nested: true
    }

    attr_reader :record, :jsonb_field, :connection, :options
    attr_accessor :query_string

    def initialize(record, jsonb_field, options = {})
      @connection = ActiveRecord::Base.connection
      @record = record
      @jsonb_field = jsonb_field
      @options = options.reverse_merge!(DEFAULT_OPTIONS)
    end

    def build(attributes)
      case attributes.keys.count
      when 0 then raise_attributes_missing
      when 1 then single_update_query(attributes)
      else multi_update_query(attributes)
      end
      self
    end

    def execute!
      connection.exec_update(query_string)
    rescue ActiveRecord::StatementInvalid => e
      raise QueryError, e.message
    end

    private

      def raise_attributes_missing
        raise QueryError, 'You need at least one JSONB field to create/update'
      end

      def single_update_query(attributes)
        keys, value = keys_and_value(attributes)

        self.query_string = build_query(keys, value)
      end

      def build_query(keys, value)
        <<~SQL
          UPDATE #{connection.quote_table_name(record.class.table_name)}
          SET #{connection.quote_column_name(jsonb_field)} = jsonb_set(
                #{connection.quote_column_name(jsonb_field)},
                #{jsonb_quote_keys(keys)},
                #{jsonb_quote_value(value)},
                #{options[:create_missing]}
              )
          WHERE id = #{connection.quote(record.id)};
        SQL
      end

      ##
      # Traverse the attributes hash, aggregating all hash keys into an
      # array and keep the last value
      def keys_and_value(attributes)
        keys = []
        if options[:nested]
          val = loop do
            key, val = attributes.flatten
            keys << key.to_s
            if val.is_a?(Hash)
              attributes = val
            else
              break val
            end
          end
        else
          keys << attributes.keys.first
          val = attributes.values.first
        end
        [keys, val]
      end

  end
end
