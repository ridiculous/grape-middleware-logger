$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ostruct'
require 'factory_girl'
require 'grape/middleware/logger'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.include FactoryGirl::Syntax::Methods
end
