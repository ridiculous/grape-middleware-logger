# Grape::Middleware::Logger
[![Code Climate](https://codeclimate.com/github/ridiculous/grape-middleware-logger/badges/gpa.svg)](https://codeclimate.com/github/ridiculous/grape-middleware-logger) [![Gem Version](https://badge.fury.io/rb/grape-middleware-logger.svg)](http://badge.fury.io/rb/grape-middleware-logger)

If you wanna use this gem, you'll need to be running Grape master [#dd0cae27](https://github.com/intridea/grape/commit/dd0cae274ee0017a22deef5e282b75cf25d65385) (April 30) or later. Otherwise, you'll have to wait for the release of v0.12.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape', github: 'intridea/grape', branch: 'master', ref: 'dd0cae274ee0017a22deef5e282b75cf25d65385'
gem 'grape-middleware-logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-middleware-logger

## Usage
    
    class API < Grape::API
      use Grape::Middleware::Logger
    end
    
Using Grape with Rails? Add consistent logging and param filtering with

    use Grape::Middleware::Logger, { 
      logger: Rails.logger, 
      filter: ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
    }
    
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
