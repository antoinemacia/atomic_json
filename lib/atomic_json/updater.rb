# frozen_string_literal: true

module AtomicJson
  module Updater

    class InvalidColumnError < StandardError; end
    class InvalidFieldTypeError < StandardError; end
    class InvalidAttributesTypeError < StandardError; end
    class InvalidObjectTypeError < StandardError; end

    INVALID_FIELD_ERROR_MESSAGE = 'Field to update must be a string or symbol'
    INVALID_ATTRS_ERROR_MESSAGE = 'Attributes to update must be a hash'
    INVALID_COLUMN_ERROR_MESSAGE = 'ActiveRecord column needs to be of type JSONB'
    INVALID_OBJECT_ERROR_MESSAGE = 'Calling object should inherit from ActiveRecord::Base'

    class << self

      def jsonb_update_columns!(field, attributes = {})
        check_valid_args(field, attributes)
        raise InvalidColumnError, INVALID_COLUMN_ERROR_MESSAGE unless type_for_attribute(field).type == :jsonb
        raise InvalidColumnError, INVALID_OBJECT_ERROR_MESSAGE unless self.class.is_a?(ActiveRecord::Base)
        query = Query.new(self, field).build(attributes)
        ActiveRecord::Base.execute(query)
      end

      private

        def check_valid_args(field, attributes)
          raise InvalidFieldTypeError, INVALID_FIELD_ERROR_MESSAGE unless field.is_a?(String) || field.is_a?(Symbol)
          raise InvalidAttributesTypeError, INVALID_ATTRS_ERROR_MESSAGE unless attributes.is_a?(Hash)
        end
    end
  end
end
