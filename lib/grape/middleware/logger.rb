require 'logger'
require 'grape'

class Grape::Middleware::Logger < Grape::Middleware::Globals
  BACKSLASH = '/'.freeze

  attr_reader :logger

  class << self
    attr_accessor :logger, :filter, :on_parameters

    def default_logger
      default = Logger.new(STDOUT)
      default.formatter = ->(*args) { args.last.to_s << "\n".freeze }
      default
    end
  end

  def initialize(_, options = {})
    super
    @options[:filter] ||= self.class.filter
    @logger = options[:logger] || self.class.logger || self.class.default_logger
  end

  def before
    start_time
    # sets env['grape.*']
    super
    logger.info ''
    logger.info %Q(Started %s "%s" at %s) % [
      env[Grape::Env::GRAPE_REQUEST].request_method,
      env[Grape::Env::GRAPE_REQUEST].path,
      start_time.to_s
    ]
    logger.info %Q(Processing by #{processed_by})
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
      status, _, _ = *@app_response
      after(status)
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
    request_params = env[Grape::Env::GRAPE_REQUEST_PARAMS].to_hash
    formatter = Grape::Middleware::Formatter.new(app)
    formatter.instance_variable_set :@env, env
    # @note parses and assigns params to @env[Grape::Env::RACK_REQUEST_FORM_HASH]
    formatter.before
    request_params.merge! env[Grape::Env::RACK_REQUEST_FORM_HASH] if env[Grape::Env::RACK_REQUEST_FORM_HASH]
    request_params.merge! env['action_dispatch.request.request_parameters'] if env['action_dispatch.request.request_parameters']
    if @options[:filter]
      @options[:filter].filter(request_params)
    else
      request_params
    end
  end

  def start_time
    @start_time ||= Time.now
  end

  def processed_by
    endpoint = env[Grape::Env::API_ENDPOINT]
    result = []
    if endpoint.namespace == BACKSLASH
      result << ''
    else
      result << endpoint.namespace
    end
    result.concat endpoint.options[:path].map { |path| path.to_s.sub(BACKSLASH, '') }
    endpoint.options[:for].to_s << result.join(BACKSLASH)
  end
end

# @description Override formatter #before so we don't read and parse the env['rack.input'] value twice
Grape::Middleware::Formatter.send :define_method, :before do
  negotiate_content_type
  read_body_input unless env.key? Grape::Env::RACK_REQUEST_FORM_HASH
end

if defined?(Rails)
  require_relative 'logger/railtie'
end
