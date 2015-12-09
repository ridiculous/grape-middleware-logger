# Grape::Middleware::Logger
[![Code Climate](https://codeclimate.com/github/ridiculous/grape-middleware-logger/badges/gpa.svg)](https://codeclimate.com/github/ridiculous/grape-middleware-logger) [![Gem Version](https://badge.fury.io/rb/grape-middleware-logger.svg)](http://badge.fury.io/rb/grape-middleware-logger)
[![Build Status](https://travis-ci.org/ridiculous/grape-middleware-logger.svg)](https://travis-ci.org/ridiculous/grape-middleware-logger)

Simple logger for Grape apps. Logs request path, parameters, status and time taken. Also logs exceptions and error responses (thrown by `error!`).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape', '>= 0.12.0'
gem 'grape-middleware-logger'
```

## Usage
```ruby
class API < Grape::API
  use Grape::Middleware::Logger
end
```

#### Rails
Using Grape with Rails? `Rails.logger` will be used by default.

#### Custom setup
Want to customize the logging? You can provide a `logger` option.

Example using a CustomLogger and parameter sanitization:
```ruby
use Grape::Middleware::Logger, {
  logger: CustomLogger.new,
  filter: ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
}
```
The `logger` option can be any object that responds to `.info(msg)`

The `filter` option can be any object that responds to `.filter(params_hash)`

## Example output
Get
```
Started GET "/v1/reports/101"
  Parameters: {"id"=>"101"}
Completed 200 in 6.29ms
```
Error
```
Started GET "/v1/reports/101"
  Parameters: {"id"=>"101"}
  Error: {:error=>"undefined something something bad", :detail=>"Whoops"}
Completed 422 in 6.29ms
```

## Credits

Big thanks to jadent's question/answer on [stackoverflow](http://stackoverflow.com/questions/25048163/grape-using-error-and-grapemiddleware-after-callback)
for easily logging error responses. Borrowed some motivation from the [grape_logging](https://github.com/aserafin/grape_logging) gem
and would love to see these two consolidated at some point.

## Contributing

1. Fork it ( https://github.com/ridiculous/grape-middleware-logger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
