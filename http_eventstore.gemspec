# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'http_eventstore'
  spec.version       = '0.1.1'
  spec.authors       = ['Tomasz Rybczyński']
  spec.email         = ['tomek.rybka@gmail.com', 'dev@arkency.com']

  spec.summary       = %q{HttpEventstore is a HTTP connector to the Greg's Event Store.}
  spec.description   = %q{HttpEventstore is a HTTP connector to the Greg's Event Store.}
  spec.homepage      = "https://github.com/arkency/http_eventstore"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'

  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'json'
  spec.add_dependency 'hashie'
end
