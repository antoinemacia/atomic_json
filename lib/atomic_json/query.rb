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

    delegate :quote_column_name, :quote_table_name, :quote, to: :connection

    def initialize(record, jsonb_field, options = {})
      @connection = ActiveRecord::Base.connection
      @record = record
      @jsonb_field = jsonb_field
      @options = options.reverse_merge!(DEFAULT_OPTIONS)
    end

    def build(_attributes)
      raise NotImplementedError
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

  end
end
