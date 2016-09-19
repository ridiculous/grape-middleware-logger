require 'rack/head'

class Grape::Middleware::Logger
  module RackHeadOverride
    def call(env)
      start_time = Time.now
      response = super
      if env && env['grape.middleware.logger.text']
        env['grape.middleware.logger.text'] << "Completed #{response[0]} in #{((Time.now - start_time) * 1000).round(2)}ms\n"
        env['grape.middleware.logger'].info env.delete('grape.middleware.logger.text')
      end
      response
    end
  end
end

Rack::Head.prepend Grape::Middleware::Logger::RackHeadOverride
