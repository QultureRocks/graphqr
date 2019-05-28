
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphqr/version"

Gem::Specification.new do |spec|
  spec.name          = "graphqr"
  spec.version       = Graphqr::VERSION
  spec.authors       = ["Manuel Puyol", "Eric La Rosa", "João Batista Marinho"]
  spec.email         = ["manuelpuyol@gmail.com", "eric@rosa.la", "joao@qulture.rocks"]

  spec.summary       = %q{Extensions and helpers for graphql-ruby}
  spec.description   = %q{Extensions and helpers for graphql-ruby}
  spec.homepage      = "https://github.com/QultureRocks/graphqr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rubocop', ['>= 0.3', '< 1']
end
