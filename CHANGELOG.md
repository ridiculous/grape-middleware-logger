1.12.0 (5/13/2019)
==================
* [#25] Support Rails 6.0.0 (Thanks [@serggl](https://github.com/serggl))

1.9.0 (7/7/2017)
==================
* [#19] Support Grape 1.0.0 (Thanks [@badlamer](https://github.com/badlamer))

1.8.0 (4/22/2017)
==================
* [#17] Add a `:headers` option, which can be either `:all` or an array of strings. (Thanks [@yamamotok](https://github.com/yamamotok))

1.7.1 (11/1/2016)
==================
* Log the error class name (https://github.com/ridiculous/grape-middleware-logger/pull/13)

1.7.0 (8/2/2016)
==================

* Bump Grape dependency to 0.17
* Encourage `insert_after` when mounting to properly include query and post data

  ```ruby    
   insert_after Grape::Middleware::Formatter, Grape::Middleware::Logger
  ```

1.6.0 (4/4/2016)
==================

* Can use default rake command to run test suite
* Fix [#4](https://github.com/ridiculous/grape-middleware-logger/issues/4), missing JSON parameters from POST requests
* Grape::Middleware::Formatter#before is Ruby 1.9.3 friendly

1.5.1 (12/15/2015)
==================

* Refactor logger conditional to use coercion and parallel assignment


1.5.0 (12/12/2015)
==================

* Use Railtie to setup default configuration for Rails apps
* Stop logging the namespace
