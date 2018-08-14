# frozen_string_literal: true

require 'atomic_json/validations'
require 'atomic_json/query_builder'

module AtomicJson
  class Query

    include Validations

    attr_reader :record, :connection, :query_builder
    attr_accessor :query_string

    delegate :quote_column_name, :quote_table_name, :quote, to: :connection

    def initialize(record)
      validate_record!(record)
      @record = record
      @connection = ActiveRecord::Base.connection
      @query_builder = QueryBuilder.new(@record, @connection)
    end

    def build(attributes, touch: false)
      validate_attributes!(record, attributes)
      self.query_string = query_builder.build(attributes, touch)
      self
    end

    def execute!
      connection.exec_update(query_string, 'SQL')
    rescue ActiveRecord::StatementInvalid => e
      raise Error, e.message
    end

    def to_s
      query_string
    end

  end
end
