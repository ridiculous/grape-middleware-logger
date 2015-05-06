require 'grape/middleware/logger/version'
require 'logger'

module Grape
  module Middleware
    class Logger < Grape::Middleware::Globals

      #
      # Overrides
      #

      def before
        @start_time = Time.now
        super
        logger.info ''
        logger.info %Q(Started #{env['grape.request'].request_method} "#{env['grape.request'].path}")
        logger.info %Q(  Parameters: #{parameters})
      end

      def after(status)
        logger.info "Completed #{status} in #{((Time.now - @start_time) * 1000).round(2)}ms"
        logger.info ''
      end

      def call!(env)
        @env = env
        before
        error = catch(:error) { @app_response = @app.call(@env); nil }
        if error
          after_failure(error)
          throw(:error, error)
        else
          after(@app_response.first)
        end
        @app_response
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
        filter_params(request_params)
      end

      def filter_params(params)
        if @options[:filter]
          @options[:filter].filter(params)
        else
          params
        end
      end

      def logger
        @logger ||= @options[:logger] || Logger.new(STDOUT)
      end
    end
  end
end
