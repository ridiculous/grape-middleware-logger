FactoryGirl.define do
  class ExpectedEnv < Hash
    attr_accessor :grape_request, :params, :post_params, :rails_post_params, :grape_endpoint
  end

  class ParamFilter
    attr_accessor :list

    def filter(opts)
      opts.each_pair { |key, val| val[0..-1] = '[FILTERED]' if list.include?(key) }
    end
  end

  class TestAPI
  end

  class App
    attr_accessor :response

    def call(_env)
      response
    end
  end

  factory :param_filter do
    list %w[password secret]
  end

  require 'rack/rewindable_input'

  factory :expected_env do
    grape_request { build :grape_request }
    grape_endpoint { build(:grape_endpoint) }
    params { grape_request.params }
    headers { grape_request.headers }
    post_params { { 'secret' => 'key', 'customer' => [] } }
    rails_post_params { { 'name' => 'foo', 'password' => 'access' } }
    other_env_params { {} }

    initialize_with do
      new.merge(
        'REQUEST_METHOD' => 'POST',
        'PATH_INFO' => '/api/1.0/users',
        'action_dispatch.request.request_parameters' => rails_post_params,
        Grape::Env::GRAPE_REQUEST => grape_request,
        Grape::Env::GRAPE_REQUEST_PARAMS => params,
        Grape::Env::GRAPE_REQUEST_HEADERS => headers,
        Rack::RACK_REQUEST_FORM_HASH => post_params,
        Grape::Env::API_ENDPOINT => grape_endpoint
      ).merge(other_env_params)
    end

    trait :prefixed_basic_headers do
      other_env_params { {
        'HTTP_VERSION' => 'HTTP/1.1',
        'HTTP_CACHE_CONTROL' => 'max-age=0',
        'HTTP_USER_AGENT' => 'Mozilla/5.0',
        'HTTP_ACCEPT_LANGUAGE' => 'en-US'
      } }
    end

  end

  factory :grape_endpoint, class: Grape::Endpoint do
    settings { Grape::Util::InheritableSetting.new }
    options {
      {
        path: [:users],
        method: 'get',
        for: TestAPI
      }
    }

    initialize_with { new(settings, options) }

    trait :complex do
      options {
        {
          path: ['/users/:name/profile'],
          method: 'put',
          for: TestAPI
        }
      }
    end
  end

  factory :namespaced_endpoint, parent: :grape_endpoint do
    initialize_with do
      new(settings, options).tap do |me|
        me.namespace_stackable(:namespace, Grape::Namespace.new('/admin', {}))
      end
    end
  end

  factory :app_response, class: Rack::Response do
    initialize_with { new('Hello World', 200, {}) }
  end

  factory :grape_request, class: OpenStruct do
    headers { {} }

    initialize_with {
      new(request_method: 'POST', path: '/api/1.0/users', headers: headers, params: { 'id' => '101001' })
    }

    trait :basic_headers do
      headers { {
        'Version' => 'HTTP/1.1',
        'Cache-Control' => 'max-age=0',
        'User-Agent' => 'Mozilla/5.0',
        'Accept-Language' => 'en-US'
      } }
    end
  end

  factory :app do
    response { build :app_response }
  end

end
