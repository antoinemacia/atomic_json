# frozen_string_literal: true

module AtomicJson
  class TypeValidation

    class Error < StandardError; end

    ERRORS = {
      field: 'Field to update must be a string or symbol',
      attributes: 'Attributes to update must be a hash',
      column: 'ActiveRecord column needs to be of type JSONB'
    }

    attr_reader :record, :field, :attributes

    def initialize(record, field, attributes)
      @record = record
      @field = field
      @attributes = attributes
    end

    def validate_types!
      ERRORS.each do |name, message|
        raise(Error, message) unless send("valid_#{name}_type?")
      end
    end

    private

      def valid_field_type?
        field.is_a?(String) || field.is_a?(Symbol)
      end

      def valid_column_type?
        record.type_for_attribute(field.to_s).type == :jsonb
      end

      def valid_attributes_type?
        attributes.is_a?(Hash)
      end

  end
end
