0.17.0 (8/2/2016)
==================

* Bump Grape dependency to 0.17
* Remove hack now that we can mount after the formatter middleware

0.16.0 (4/4/2016)
==================

* Can use default rake command to run test suite
* Fix [#4](https://github.com/ridiculous/grape-middleware-logger/issues/4), missing JSON parameters from POST requests
* Grape::Middleware::Formatter#before is Ruby 1.9.3 friendly

0.15.1 (12/15/2015)
==================

* Refactor logger conditional to use coercion and parallel assignment


0.15.0 (12/12/2015)
==================

* Use Railtie to setup default configuration for Rails apps
* Stop logging the namespace
