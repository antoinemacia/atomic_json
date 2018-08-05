# frozen_string_literal: true

module AtomicJson
  class TypeValidation

    class Error < StandardError; end

    ERRORS = {
      payload: 'Payload to update must be a hash',
      column: 'ActiveRecord column needs to be of type JSONB'
    }

    attr_reader :record, :column, :payload

    def initialize(record, column, payload)
      @record = record
      @column = column
      @payload = payload
    end

    def validate_types!
      ERRORS.each do |name, message|
        raise(Error, message) unless send("valid_#{name}_type?")
      end
    end

    private

      def valid_column_type?
        record.type_for_attribute(column.to_s).type == :jsonb
      end

      def valid_payload_type?
        payload.is_a?(Hash)
      end

  end
end
