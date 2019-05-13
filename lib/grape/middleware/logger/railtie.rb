class Grape::Middleware::Logger::Railtie < Rails::Railtie
  options = Rails::VERSION::MAJOR < 5 ? { after: :load_config_initializers } : {}
  initializer 'grape.middleware.logger', options do
    Grape::Middleware::Logger.logger = Rails.application.config.logger || Rails.logger.presence
    parameter_filter_class = if Rails::VERSION::MAJOR >= 6
                               ActiveSupport::ParameterFilter
                             else
                               ActionDispatch::Http::ParameterFilter
                             end
    Grape::Middleware::Logger.filter = parameter_filter_class.new Rails.application.config.filter_parameters
  end
end
