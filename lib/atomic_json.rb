# frozen_string_literal: true

require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

module AtomicJson

  def json_update(json, attrs = {})

  end

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.public_send(:include, JsonbAccessor)
end
