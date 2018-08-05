# frozen_string_literal: true

module AtomicJson
  module Updater

    extend ActiveSupport::Concern

    def json_update_columns(payload)
      Query.new(self)
        .build(payload)
        .execute!
    end

    def json_update(payload)
      run_callbacks(:save) do
        Query.new(self)
          .build(payload, touch: true)
          .execute!
        validate
      end
    end

  end
end
