class Grape::Middleware::Logger::Railtie < Rails::Railtie
  options = Rails::VERSION::MAJOR < 5 ? { after: :load_config_initializers } : {}
  initializer 'grape.middleware.logger', options do
    Grape::Middleware::Logger.logger = Rails.application.config.logger || Rails.logger.presence
    Grape::Middleware::Logger.filter = ActionDispatch::Http::ParameterFilter.new Rails.application.config.filter_parameters
  end
end
