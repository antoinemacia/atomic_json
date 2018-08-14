# frozen_string_literal: true

require 'atomic_json/query'

module AtomicJson
  module QueryMethods

    extend ActiveSupport::Concern

    def json_update(input)
      run_callbacks(:save) do
        Query.new(self)
          .build(input, touch: true)
          .execute!
        reload.validate
      end
    end

    def json_update!(input)
      run_callbacks(:save) do
        Query.new(self)
          .build(input, touch: true)
          .execute!
        reload.validate!
      end
    end

    def json_update_columns(input)
      Query.new(self)
        .build(input)
        .execute!
    end

  end
end
