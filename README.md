# Grape::Middleware::Logger

Works if you're running directly off Grape master. Otherwise, you'll have to wait for the release of Grape v0.12.0

## Installation

Add this line to your application's Gemfile:

```ruby
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
