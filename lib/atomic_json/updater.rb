# frozen_string_literal: true

module AtomicJson
  module Updater

    extend ActiveSupport::Concern

    def json_update_column(payload = {})
      # TypeValidation.new(self, payload).validate_types!
      Query.new(self)
        .build(payload)
        .execute!
    end

    def json_update(column, payload = {})
      TypeValidation.new(self, column, payload).validate_types!
      run_callbacks(:save) do
        Query.new(self)
          .build(payload, touch: true)
          .execute!
        validate
      end
    end

  end
end
