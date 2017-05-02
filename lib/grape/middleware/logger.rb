require 'logger'
require 'grape'

class Grape::Middleware::Logger < Grape::Middleware::Globals
  BACKSLASH = '/'.freeze

  attr_reader :logger

  class << self
    attr_accessor :logger, :filter, :headers

    def default_logger
      default = Logger.new(STDOUT)
      default.formatter = ->(*args) { args.last.to_s << "\n".freeze }
      default
    end
  end

  def initialize(_, options = {})
    super
    @options[:filter] ||= self.class.filter
    @options[:headers] ||= self.class.headers
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
    logger.info %Q(     Headers: #{headers})
    logger.info %Q(  Parameters: #{parameters})
    logger.info %Q(  Headers: #{headers}) if @options[:headers]
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
    logger.info %Q(  #{e.class.name}: #{e.message})
    after(500)
  end

  def after_failure(error)
    logger.info %Q(  Error: #{error[:message]}) if error[:message]
    after(error[:status])
  end

  def headers
    env['grape.request.headers']
  end

  def parameters
    request_params = env[Grape::Env::GRAPE_REQUEST_PARAMS].to_hash
    request_params.merge! env[Grape::Env::RACK_REQUEST_FORM_HASH] if env[Grape::Env::RACK_REQUEST_FORM_HASH]
    request_params.merge! env['action_dispatch.request.request_parameters'] if env['action_dispatch.request.request_parameters']
    if @options[:filter]
      @options[:filter].filter(request_params)
    else
      request_params
    end
  end

  def headers
    request_headers = env[Grape::Env::GRAPE_REQUEST_HEADERS].to_hash
    return Hash[request_headers.sort] if @options[:headers] == :all

    headers_needed = Array(@options[:headers])
    result = {}
    headers_needed.each do |need|
      result.merge!(request_headers.select { |key, value| need.to_s.casecmp(key).zero? })
    end
    Hash[result.sort]
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

require_relative 'logger/railtie' if defined?(Rails)
