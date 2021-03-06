$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler/setup'
require 'mocha_standalone'
require 'rack/test'

require 'sequel'
DB = Sequel.connect(ENV['TEST_DATABASE_URL'] || 'postgres://localhost/tent_server_test')

require 'tentd'
require 'fabrication'
require 'tentd/core_ext/hash/slice'
require 'girl_friday'
require 'tentd/notifications/girl_friday'

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }

ENV['RACK_ENV'] ||= 'test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include JsonRequest
  config.mock_with :mocha

  config.around do |suite|
    with_constants "TentD::Notifications::NOTIFY_ENTITY_QUEUE" => [], "TentD::Notifications::TRIGGER_QUEUE" => [] do
      suite.run
    end
  end

  config.before(:each) do
    DB.tables.each { |table_name|
      DB[table_name].delete
    }
    TentD::Model::User.current = TentD::Model::User.first_or_create
  end

  config.before(:suite) do
    GirlFriday::WorkQueue.immediate!
  end
end
