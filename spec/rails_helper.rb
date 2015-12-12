require 'rails'

class MyRailsApp < Rails::Application
  RailsLogger = Class.new Logger
  config.logger = RailsLogger.new(Tempfile.new '')
  config.filter_parameters += [:password]
end

require 'spec_helper'
Grape::Middleware::Logger::Railtie.run_initializers
