class RailsApp < Rails::Application
  RailsLogger = Class.new Logger
  config.logger = RailsLogger.new(Tempfile.new '')
  config.filter_parameters += [:password]
end
