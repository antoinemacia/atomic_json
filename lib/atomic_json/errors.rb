module AtomicJson

  class Error < StandardError
  end

  module Errors
    ##
    # Thrown when attributes
    class TypeError < AtomicJson::Error
    end

    ##
    # Thrown when top level keys provided does not correspond to a JSON/JSONB column
    # on the updated ActiveRecord model
    class InvalidColumnTypeError < AtomicJson::Error
    end

    ##
    # Thrown when the attributes to update are flagged as read-only
    class ReadOnlyAttributeError < AtomicJson::Error
    end

    ##
    # Thrown on specific ActiveRecord errors
    class ActiveRecordError < AtomicJson::Error
    end
  end
end
