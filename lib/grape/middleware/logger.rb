require 'logger'
require 'grape/middleware/globals'

# avoid superclass mismatch when version file gets loaded first
Grape::Middleware.send :remove_const, :Logger if defined? Grape::Middleware::Logger
module Grape
  module Middleware
    class Logger < Grape::Middleware::Globals

      def before
        start_time
        super
        logger.info ''
        logger.info %Q(Started #{env['grape.request'].request_method} "#{env['grape.request'].path}")
        logger.info %Q(  Parameters: #{parameters})
      end

      def call!(env)
        @env = env
        before
        error = catch(:error) { @app_response = @app.call(@env); nil }
        if error.nil?
          after(@app_response.first)
        else
          after_failure(error)
          throw(:error, error)
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

      def after_failure(error)
        logger.info %Q(  Error: #{error[:message]}) if error[:message]
        after(error[:status])
      end

      def parameters
        request_params = env['grape.request.params'].to_hash
        request_params.merge!(env['action_dispatch.request.request_parameters'] || {})
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
        @logger ||= @options[:logger] || ::Logger.new(STDOUT)
      end
    end
  end
end

require 'grape/middleware/logger/version'
