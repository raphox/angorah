ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'database_cleaner/mongoid'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize_setup do |worker|
    DatabaseCleaner.start
  end

  parallelize_teardown do |worker|
    DatabaseCleaner.clean
  end

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Add more helper methods to be used by all tests here...
end
