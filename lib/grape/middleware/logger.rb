require 'logger'
require 'grape'

class Grape::Middleware::Logger < Grape::Middleware::Globals
  BACKSLASH = '/'.freeze

  attr_reader :logger

  class << self
    attr_accessor :logger, :filter

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
    @io = StringIO.new
  end

  def before
    # sets env['grape.*']
    @io.reopen
    super
    # Pass along the configured logger
    env['grape.middleware.logger'] = @logger
    @io.puts %Q(\nStarted %s "%s" at %s) % [
      env[Grape::Env::GRAPE_REQUEST].request_method,
      env[Grape::Env::GRAPE_REQUEST].path,
      Time.now.to_s
    ]
    @io.puts %Q(Processing by #{processed_by})
    @io.puts %Q(  Parameters: #{parameters})
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
      after
    end
    @app_response
  end

  # Save the string to be flushed at the end of the request by Rack::Head(Override)
  def after
    env['grape.middleware.logger.text'] = @io.string
    @io.close
  end

  #
  # Helpers
  #

  def after_exception(e)
    @io.puts %Q(  #{e.class.name}: #{e.message})
    after
  end

  def after_failure(error)
    @io.puts %Q(  Error: #{error[:message]}) if error[:message]
    after
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

# This is required to properly log the status code of the response
# The Grape::Endpoint#build_stack method builds the default stack, including the necessary middlewares for Grape to work
# At the top of the default middleware stack is Rack::Head
require_relative 'logger/rack_head_override' if defined?(Rack::Head)
