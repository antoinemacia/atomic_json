# frozen_string_literal: true

module AtomicJson
  class Query

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
      case attributes.keys.count
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
        keys, value = keys_and_value(attributes)
        self.query = build_query(keys, value)
      end

      def build_query(keys, value)
        <<~SQL
            UPDATE #{connection.quote_table_name(record.class.table_name)}
            SET #{connection.quote_column_name(jsonb_field)} = jsonb_set(
                  #{connection.quote_column_name(jsonb_field)},
                  #{jsonb_quote_keys(keys)},
                  #{jsonb_quote_value(value)},
                  #{create_missing}
                )
            WHERE id = #{connection.quote(record.id)};
        SQL
      end

      ##
      # Traverse the attributes hash, aggregating all hash keys into an
      # array and keep the last value
      def keys_and_value(attributes)
        keys = []
        value = loop do
          key, values = attributes.flatten
          keys << key.to_s
          if values.is_a?(Hash)
            attributes = values
          else
            break values
          end
        end
        [keys, value]
      end

      def jsonb_quote_keys(keys)
        "'{#{keys.join(',')}}'"
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
