# frozen_string_literal: true

module AtomicJson
  module Updater

    extend ActiveSupport::Concern

    included do
      def jsonb_update_column(field, payload = {}, options = {})
        TypeValidation.new(self, field, payload).validate_types!
        Query.new(self, field, options)
          .build(payload)
          .execute!
      end
    end

  end
end
