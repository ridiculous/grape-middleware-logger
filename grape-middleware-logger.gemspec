# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'grape-middleware-logger'
  spec.version       = '1.2.0'
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Ryan Buckley']
  spec.email         = ['arebuckley@gmail.com']
  spec.summary       = %q{A logger for the Grape framework}
  spec.description   = %q{Logging middleware for the Grape framework, similar to what Rails offers}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'grape', '>= 0.12', '< 1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>= 3.2', '< 4'
end
