# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_explorer/version'

Gem::Specification.new do |spec|
  spec.name          = "active_explorer"
  spec.version       = ActiveExplorer::VERSION
  spec.authors       = ["Marek Ulicny"]
  spec.email         = ["xulicny@gmail.com"]

  spec.summary       = "Visualization of data and associations represented by Active Record."
  spec.description   = "Visualization of data and associations represented by Active Record."
  spec.homepage      = 'https://github.com/rascasone/active_explorer'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'ruby-graphviz', '~> 1.2'
  spec.add_dependency 'activerecord', '>= 4.0.13'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec' , "~> 3.0"
  spec.add_development_dependency "rspec-nc", "~> 0.3"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency 'awesome_print', "~> 1.7"
  spec.add_development_dependency 'factory_girl', "~> 4.7"
  spec.add_development_dependency 'appraisal', "~> 2.1"
  spec.add_development_dependency 'pry', "~> 0.10"
  spec.add_development_dependency 'pry-byebug', "~> 3.4"
end
