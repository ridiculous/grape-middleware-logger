require 'logger'
require 'grape'

class Grape::Middleware::Logger < Grape::Middleware::Globals
  attr_reader :logger

  def initialize(_, options = {})
    super
    @logger = options[:logger]
    @logger ||= Rails.logger if defined?(Rails) && Rails.logger.present?
    @logger ||= Logger.new(STDOUT)
  end

  def before
    start_time
    super # sets env['grape.*']
    logger.info ''
    logger.info %Q(Started %s "%s" at %s) % [
      env['grape.request'].request_method,
      env['grape.request'].path,
      start_time.to_default_s
    ]
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
      # Usually a rack response object is returned: https://github.com/ruby-grape/grape/blob/master/UPGRADING.md#changes-in-middleware
      # However, rack/auth/abstract/handler.rb still returns an array instead of a rack response object.
      if @app_response.is_a?(Array)
        after(@app_response[0])
      else
        after(@app_response.status)
      end
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
end
