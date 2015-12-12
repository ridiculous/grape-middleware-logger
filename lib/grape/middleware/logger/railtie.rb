class Grape::Middleware::Logger::Railtie < Rails::Railtie
  initializer 'grape.middleware.logger' do
    Grape::Middleware::Logger.logger = ::Rails.application.config.logger
    Grape::Middleware::Logger.filter = ::ActionDispatch::Http::ParameterFilter.new(::Rails.application.config.filter_parameters)
  end
end
