# frozen_string_literal: true
require 'atomic_json/json_query_helpers'

module AtomicJson
  class Query

    class QueryError < StandardError; end

    include AtomicJson::JsonQueryHelpers

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

    def build(_attributes)
      raise NotImplementedError
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

      def raise_attributes_missing
        raise QueryError, 'You need at least one JSONB field to create/update'
      end

  end
end
