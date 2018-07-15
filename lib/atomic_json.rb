# frozen_string_literal: true

require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
require 'atomic_json/version'
require 'atomic_json/updater'
require 'atomic_json/query'

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.public_send(:include, AtomicJson::Updater)
end
