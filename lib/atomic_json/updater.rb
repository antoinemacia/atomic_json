# frozen_string_literal: true

module AtomicJson
  module Updater
    extend ActiveSupport::Concern

    included do
      def jsonb_update_columns(field, attributes = {}, options = {})
        TypeValidation.new(self, field, attributes)
          .validate_types!

        Query.new(self, field, options)
          .build(attributes)
          .execute!
      end
    end

  end
end
