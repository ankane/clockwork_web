require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"

Combustion.path = "test/internal"
Combustion.initialize! :action_controller do
  config.load_defaults Rails::VERSION::STRING.to_f
end
