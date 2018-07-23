# frozen_string_literal: true

module AtomicJson
  class QueryBuilder

    class QueryError < StandardError; end

    attr_reader :record, :jsonb_field, :create_missing, :connection, :options
    attr_accessor :query

    def initialize(record, jsonb_field, create_missing, options = {})
      @connection = ActiveRecord::Base.connection
      @record = record
      @jsonb_field = jsonb_field
      @create_missing = create_missing
      @options = options
    end

    def build(attributes)
      self.query = case attributes.keys.count
        when 0 then raise_attributes_missing
        when 1 then single_update_query(attributes)
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

    def raise_attributes_missing
      raise QueryError, 'You need at least one JSONB field to create/update'
    end

    def single_update_query(attributes)
      <<~SQL
            UPDATE #{connection.quote_table_name(record.class.table_name)}
            SET #{connection.quote_column_name(jsonb_field)} = jsonb_set(
                  #{connection.quote_column_name(jsonb_field)},
                  #{jsonb_quote_key(key)},
                  #{jsonb_quote_value(values)},
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
        when Hash
          options[:atomic] ? %('#{value}') : %('#{value.to_json}')
        else %('#{value.to_json}')
      end
    end
  end
end
