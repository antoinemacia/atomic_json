# frozen_string_literal: true

module AtomicJson
  module Updater

    extend ActiveSupport::Concern

    included do
      def json_update_column(field, payload = {})
        TypeValidation.new(self, field, payload).validate_types!
        Query.new(self, field)
          .build(payload)
          .execute!
      end
    end

  end
end
