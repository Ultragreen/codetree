# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codetree/version'

Gem::Specification.new do |spec|
  spec.name          = "codetree"
  spec.version       = Codetree::VERSION
  spec.authors       = ["Romain GEORGES"]
  spec.email         = ["romain@ultragreen.net"]
  spec.description   = %q{Scan code to map methods or classes or modules and build tree of modules namespaces}
  spec.summary       = %q{Usefull tools for code audit commands}
  spec.homepage      = "http://www.ultragreen.net"
  spec.license       = "BSD"
  spec.require_paths << 'bin'
  spec.bindir = 'bin'
  spec.executables = Dir["bin/*"].map!{|item| item.gsub("bin/","")}
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency "ruby_parser"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('yard')
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('roodi')
  spec.add_development_dependency('code_statistics')
  spec.add_development_dependency('yard-rspec')

end
