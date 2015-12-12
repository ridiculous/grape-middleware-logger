require 'rails'
require_relative 'fixtures/rails_app'
require 'spec_helper'
Grape::Middleware::Logger::Railtie.run_initializers
