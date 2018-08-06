# frozen_string_literal: true

require 'atomic_json/errors'

module AtomicJson
  class Validator

    attr_reader :record, :attributes

    def initialize(record, attributes)
      @record = record
      @attributes = attributes
    end

    ##
    # Validations taken from ActiveRecord::Persistence module
    def validate_record!
      raise Errors::ActiveRecordError, 'cannot update a new record' if record.new_record?
      raise Errors::ActiveRecordError, 'cannot update a destroyed record' if record.destroyed?
      self
    end

    def validate_attributes!
      raise Errors::TypeError, 'Payload to update must be a hash' unless valid_payload_type?
      attributes.each_key do |key|
        raise Errors::ReadOnlyAttributeError, "#{key} is marked as readonly" if read_only_attribute?(key)
        raise Errors::InvalidColumnTypeError, 'ActiveRecord column needs to be of type JSON or JSONB' unless valid_column_type?(key)
      end
      self
    end

    private

      def valid_payload_type?
        attributes.is_a?(Hash)
      end

      def read_only_attribute?(key)
        record.class.readonly_attributes.include?(key.to_s)
      end

      def valid_column_type?(key)
        %i[json jsonb].include?(record.type_for_attribute(key.to_s).type)
      end
  end
end
