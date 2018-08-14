module AtomicJson

  ##
  # Base error class
  class Error < StandardError
  end

  ##
  # Thrown when attributes
  class TypeError < Error
  end

  ##
  # Thrown when top level keys provided does not correspond to a JSON/JSONB column
  # on the updated ActiveRecord model
  class InvalidColumnTypeError < Error
  end

  ##
  # Thrown when the attributes to update are flagged as read-only
  class ReadOnlyAttributeError < Error
  end

  ##
  # Thrown on specific ActiveRecord errors
  class ActiveRecordError < Error
  end
end
