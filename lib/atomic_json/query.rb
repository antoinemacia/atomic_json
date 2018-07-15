# frozen_string_literal: true

module AtomicJson
  class Query

    CREATE_NEW_COLUMN = false

    attr_reader :record, :jsonb_field

    def initialize(record, jsonb_field)
      @record = record
      @jsonb_field = jsonb_field
    end

    def build(attributes)
      if attributes.keys.count > 1
        single_update_query(attributes.keys.first, attributes.values.first)
      else
        multi_update_query(attributes)
      end
    end

    private

      def single_update_query(key, value)
        <<~SQL
          UPDATE #{record.class.table_name}
          SET body = jsonb_set(#{jsonb_field}, '{#{key}}', #{value}, #{CREATE_NEW_COLUMN})
          WHERE id = #{record.id};
        SQL
      end

      def multi_update_query(hash)
      end

  end
end
