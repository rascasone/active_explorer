# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mindmapper/version'

Gem::Specification.new do |spec|
  spec.name          = "mindmapper"
  spec.version       = Mindmapper::VERSION
  spec.authors       = ["Marek Ulicny"]
  spec.email         = ["xulicny@gmail.com"]

  spec.summary       = "Automatic generation of mind maps for connected objects"
  spec.description   = "Mind maps generator for connected objects"
  spec.homepage      = 'http://www.github.com/rascasone/mindmapper'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'ruby-graphviz'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec' , '>=3.0.0'
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end