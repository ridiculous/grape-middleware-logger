require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec) do |config|
  config.pattern = 'spec/lib/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:integration) do |config|
  config.pattern = 'spec/integration/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:integration_rails) do |config|
  config.pattern = 'spec/integration_rails/**/*_spec.rb'
end

task default: [:spec, :integration, :integration_rails]
