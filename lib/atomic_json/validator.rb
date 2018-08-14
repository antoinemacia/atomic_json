# frozen_string_literal: true

require 'atomic_json/errors'

module AtomicJson
  class Validator

    attr_reader :record

    def initialize(record)
      @record = record
    end

    def validate!(attributes)
      validate_record!
      validate_attributes!(attributes)
    end

    private

      def validate_record!
        raise ActiveRecordError, 'cannot update a new record' if record.new_record?
        raise ActiveRecordError, 'cannot update a destroyed record' if record.destroyed?
      end

      def validate_attributes!(attributes)
        raise TypeError, 'Payload to update must be a hash' unless attributes.is_a?(Hash)
        attributes.each_key do |key|
          raise ReadOnlyAttributeError, "#{key} is marked as readonly" if read_only_attribute?(key)
          raise InvalidColumnTypeError, 'ActiveRecord column needs to be of type JSON or JSONB' unless valid_column_type?(key)
        end
      end

      def read_only_attribute?(key)
        record.class.readonly_attributes.include?(key.to_s)
      end

      def valid_column_type?(key)
        %i[json jsonb].include?(record.type_for_attribute(key.to_s).type)
      end
  end
end
