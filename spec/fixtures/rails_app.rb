require 'tempfile'
class RailsApp < Rails::Application
  RailsLogger = Class.new Logger
  config.logger = RailsLogger.new(Tempfile.new '')
  config.filter_parameters += [:password]
  config.eager_load = false
end
