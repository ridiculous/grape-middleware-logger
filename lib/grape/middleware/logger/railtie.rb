class Grape::Middleware::Logger::Railtie < Rails::Railtie
  initializer 'grape.middleware.logger', after: :load_config_initializers do
    Grape::Middleware::Logger.logger = Rails.application.config.logger || Rails.logger.presence
    Grape::Middleware::Logger.filter = ActionDispatch::Http::ParameterFilter.new Rails.application.config.filter_parameters
  end
end
