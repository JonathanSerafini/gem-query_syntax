# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'query_syntax/version'

Gem::Specification.new do |spec|
  spec.name          = "query_syntax"
  spec.version       = QuerySyntax::VERSION
  spec.authors       = ["Jonathan Serafini"]
  spec.email         = ["jonathan@lightspeedretail.com"]
  spec.summary       = "Provide chainable objects to build Chef search queries"
  spec.description   = "Provides a mechanism to craft Chef queries through object chains such as .and.or.where(key:value)"
  spec.homepage      = "https://github.com/JonathanSerafini/gem-query_syntax"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
