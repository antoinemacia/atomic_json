# frozen_string_literal: true

module AtomicJson
  module Updater
    extend ActiveSupport::Concern

    included do
      def jsonb_update!(field, attributes = {}, create_missing = false)
        TypeValidation.new(self, field, attributes)
          .validate_types!

        Query.new(self, field, create_missing)
          .build(attributes)
          .execute!
      end
    end

  end
end
