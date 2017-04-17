ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'database_cleaner'
require 'email_spec'
require "cancan/matchers"
require 'simplecov'
require 'capybara/rails'
require 'capybara/rspec'
require 'shoulda/matchers'
require 'factory_girl_rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Devise.stretches = 1
Rails.logger.level = 4

SimpleCov.start 'rails'

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
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

  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before(:example) do
    DatabaseCleaner.start
  end

  config.after(:example) do
    DatabaseCleaner.clean
  end

  config.before do
    allow_any_instance_of(Repository).to receive(:sync_github)
    allow_any_instance_of(Repository).to receive(:setup_github_hook)
    allow_any_instance_of(Repository).to receive(:copy_config_file)
    allow(Devise).to receive(:friendly_token).and_return('123456789')
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    with.library :rails
  end
end
