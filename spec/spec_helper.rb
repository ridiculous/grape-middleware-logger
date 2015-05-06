$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ostruct'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
