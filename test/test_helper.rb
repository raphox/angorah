ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'minitest/mock'
require 'database_cleaner/mongoid'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize_setup do |_worker|
    DatabaseCleaner.start
  end

  parallelize_teardown do |_worker|
    DatabaseCleaner.clean
  end

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Add more helper methods to be used by all tests here...
end

# TODO: Do test with real Neo4j
class UserNeo4jStub
  attr_reader :uuid

  def initialize(attributes)
    data = OpenStruct.new(attributes)

    @uuid = data.uuid
  end

  def update(_foo)
    true
  end

  def friends
    []
  end
end
