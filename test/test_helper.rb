# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'atomic_json'

require 'active_record'
require 'byebug'
require 'minitest/autorun'
require 'minitest/benchmark'
require 'factory_bot'

## Define mock AR models
class Order < ActiveRecord::Base; end

class Minitest::Test
  include FactoryBot::Syntax::Methods

  ## Load DB
  database = YAML.load(File.open('db/config.yml'))
  ActiveRecord::Base.establish_connection(database['test'])

  # Retrieve FactoryBot definitions
  FactoryBot.find_definitions
end

