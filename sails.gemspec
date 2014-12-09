# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('lib/sails/version')

Gem::Specification.new do |s|
  s.name        = "sails"
  s.version     = Sails.version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Lee"]
  s.email       = ["huacnlee@gmail.com"]
  s.homepage    = "https://github.com/huacnlee/sails"
  s.summary     = %q{Sails, create Thrift Server use like Rails}
  s.description = %q{Sails, create Thrift Server use like Rails}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ["sails"]
  s.require_paths = ["lib"]
  s.license       = 'MIT'

  s.add_dependency "activesupport", [">= 3.2.0"]
  s.add_dependency "thrift", [">= 0.9.0"]
  s.add_dependency "thor"
end
