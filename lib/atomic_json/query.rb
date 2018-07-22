# frozen_string_literal: true

module AtomicJson
  class Query

    class QueryError < StandardError; end

    attr_reader :record, :jsonb_field, :create_missing, :connection
    attr_accessor :query

    def initialize(record, jsonb_field, create_missing)
      @connection = ActiveRecord::Base.connection
      @record = record
      @jsonb_field = jsonb_field
      @create_missing = create_missing
    end

    def build(attributes)
      self.query = case attributes.keys.count
      when 0 then nil
      when 1 then single_update_query(attributes.keys.first, attributes.values.first)
      else multi_update_query(attributes)
      end
      self
    end

    def execute!
      connection.exec_update(query)
    rescue ActiveRecord::StatementInvalid => e
      raise QueryError, e.message
    end

    private

      def single_update_query(key, value)
        <<~SQL
          UPDATE #{connection.quote_table_name(record.class.table_name)}
          SET #{connection.quote_column_name(jsonb_field)} = jsonb_set(
                #{connection.quote_column_name(jsonb_field)},
                #{jsonb_quote_key(key)},
                #{jsonb_quote_value(value)},
                #{create_missing}
              )
          WHERE id = #{connection.quote(record.id)};
        SQL
      end

      def jsonb_quote_key(key)
        case key
        when String, Symbol then "'{#{key}}'"
        else raise TypeError
        end
      end

      def jsonb_quote_value(value)
        case value
        when String then "'\"#{connection.quote_string(value)}\"'"
        when Date, Time then "'\"#{value.iso8601}\"'"
        when nil then %('null')
        else %('#{value}')
        end
      end
  end
end
