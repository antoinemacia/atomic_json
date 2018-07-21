# frozen_string_literal: true

module AtomicJson
  class Query

    CREATE_NEW_COLUMN = false

    class QueryError < StandardError; end

    attr_reader :record, :jsonb_field, :create_missing
    attr_accessor :query

    def initialize(record, jsonb_field, create_missing)
      @record = record
      @jsonb_field = jsonb_field
      @create_missing = create_missing
    end

    def build(attributes)
      self.query = case attributes.keys.count
      when 0
        nil
      when 1
        single_update_query(attributes.keys.first, attributes.values.first)
      else
        multi_update_query(attributes)
      end
      self
    end

    def run!
      ActiveRecord::Base.connection.execute(query)
    rescue ActiveRecord::StatementInvalid => e
      raise QueryError, e.message
    end

    private

      def single_update_query(key, value)
        <<~SQL
          UPDATE #{record.class.table_name}
          SET #{jsonb_field} = jsonb_set(#{jsonb_field}, '{#{key}}', #{type_matcher(value)}, #{create_missing})
          WHERE id = #{record.id};
        SQL
      end

      def type_matcher(value)
        value.is_a?(String) ? "'\"#{value}\"'" : %('#{value}')
      end

  end
end
