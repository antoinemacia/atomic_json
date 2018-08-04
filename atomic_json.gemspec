# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atomic_json/version'

Gem::Specification.new do |spec|
  spec.name          = 'atomic_json'
  spec.version       = AtomicJson::VERSION
  spec.authors       = ['Antoine Macia']
  spec.email         = ['antoine@discolabs.com']

  spec.summary       = 'Atomic update of JSONB fields for ActiveRecord models'
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5.0'
  spec.add_dependency 'activesupport', '>= 5.0'
  spec.add_dependency 'pg', '>= 0.18.1'
  spec.add_development_dependency 'bundler', '~> 1.16.a'
  spec.add_development_dependency 'byebug', '~> 10.0.2'
  spec.add_development_dependency 'factory_bot', '~> 4.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.58.1'
  spec.add_development_dependency 'standalone_migrations', '~> 5.2.5'
end
