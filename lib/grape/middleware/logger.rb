require 'logger'
require 'grape'

# avoid superclass mismatch when version file gets loaded first
Grape::Middleware.send :remove_const, :Logger if defined? Grape::Middleware::Logger
class Grape::Middleware::Logger < Grape::Middleware::Globals
  def before
    start_time
    super # sets env['grape.*']
    logger.info ''
    logger.info %Q(Started #{env['grape.request'].request_method} "#{env['grape.request'].path}")
    logger.info %Q(  Parameters: #{parameters})
  end

  # @note Error and exception handling are required for the +after+ hooks
  #   Exceptions are logged as a 500 status and re-raised
  #   Other "errors" are caught, logged and re-thrown
  def call!(env)
    @env = env
    before
    error = catch(:error) do
      begin
        @app_response = @app.call(@env)
      rescue => e
        after_exception(e)
        raise e
      end
      nil
    end
    if error
      after_failure(error)
      throw(:error, error)
    else
      after(@app_response.status)
    end
    @app_response
  end

  def after(status)
    logger.info "Completed #{status} in #{((Time.now - start_time) * 1000).round(2)}ms"
    logger.info ''
  end

  #
  # Helpers
  #

  def after_exception(e)
    logger.info %Q(  Error: #{e.message})
    after(500)
  end

  def after_failure(error)
    logger.info %Q(  Error: #{error[:message]}) if error[:message]
    after(error[:status])
  end

  def parameters
    request_params = env['grape.request.params'].to_hash
    request_params.merge!(env['action_dispatch.request.request_parameters'] || {}) # for Rails
    if @options[:filter]
      @options[:filter].filter(request_params)
    else
      request_params
    end
  end

  def start_time
    @start_time ||= Time.now
  end

  def logger
    @logger ||= @options[:logger]
    @logger ||= defined?(Rails) && Rails.logger.present? ? Rails.logger : Logger.new(STDOUT)
  end
end

require 'grape/middleware/logger/version'
