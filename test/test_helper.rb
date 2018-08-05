# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'atomic_json'

require 'active_record'
require 'byebug'
require 'minitest/autorun'
require 'minitest/benchmark'
require 'factory_bot'

## Define mock AR models
class Order < ActiveRecord::Base

  after_commit :set_default, on: :create
  before_save :before_update_callback, on: :update

  validate :json_string_present, on: :update

  attr_accessor :before_update_ran

  def set_default
    self.before_update_ran = false
    self.updated_at = nil
  end

  def before_update_callback
    self.before_update_ran = true
  end

  def json_string_present
    errors.add(:jsonb_data, 'JSON string is missing') unless jsonb_data['string_field'].present?
  end

end

class Minitest::Test
  include FactoryBot::Syntax::Methods

  ## Load DB
  database = YAML.load(File.open('db/config.yml'))
  ActiveRecord::Base.establish_connection(database['test'])

  # Retrieve FactoryBot definitions
  FactoryBot.find_definitions
end

