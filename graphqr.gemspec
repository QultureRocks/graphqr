# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphqr/version'

Gem::Specification.new do |s|
  s.name          = 'graphqr'
  s.version       = GraphQR::VERSION
  s.authors       = ['Manuel Puyol', 'Eric La Rosa', 'João Batista Marinho']
  s.email         = ['manuelpuyol@gmail.com', 'eric@rosa.la', 'joao@qulture.rocks']

  s.summary       = 'Extensions and helpers for graphql-ruby'
  s.description   = 'Extensions and helpers for graphql-ruby'
  s.homepage      = 'https://github.com/QultureRocks/graphqr'
  s.license       = 'MIT'

  s.files = Dir['{lib}/**/*', 'LICENSE.txt', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'rubocop-thread_safety'
end
