require 'rubygems'
require 'spork'

Spork.prefork do
  require "rails/application"
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'webmock/rspec'
  require 'database_cleaner'
  require 'fakefs/spec_helpers'
  require 'email_spec'
  require "cancan/matchers"
  require 'simplecov'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  Devise.stretches = 1
  Rails.logger.level = 4

  SimpleCov.start 'rails'

  RSpec.configure do |config|
    config.mock_with :mocha

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    config.include(Support::BuildHelper)
    config.include(Support::CallbackHelper)
    config.include(Support::DelayedJobHelper)

    config.include Devise::TestHelpers, type: :controller

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  require 'factory_girl_rails'
  FactoryGirl.reload
end

