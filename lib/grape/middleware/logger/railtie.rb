class Grape::Middleware::Logger::Railtie < Rails::Railtie
  initializer 'grape.middleware.logger', after: :load_config_initializers do
    Grape::Middleware::Logger.logger = Rails.application.config.logger || Rails.logger.presence
    Grape::Middleware::Logger.filter = ActionDispatch::Http::ParameterFilter.new Rails.application.config.filter_parameters
    Grape::Middleware::Logger.on_parameters = ->(_, env, params) do
      params.merge! env['action_dispatch.request.request_parameters'] if env['action_dispatch.request.request_parameters']
    end
  end
end
