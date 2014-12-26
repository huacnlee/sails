# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('lib/sails/version')

Gem::Specification.new do |s|
  s.name        = "sails"
  s.version     = Sails.version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Lee", "P.S.V.R", "wxianfeng", "sapronlee","qhwa"]
  s.email       = ["huacnlee@gmail.com", "pmq2001@gmail.com", "wang.fl1429@gmail.com", "sapronlee@gmail.com","qhwa@163.com"]
  s.homepage    = "https://github.com/huacnlee/sails"
  s.summary     = %q{Sails, Help you to create Rails style Thrift Server}
  s.description = %q{Sails, Help you to create Rails style Thrift Server}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ["sails"]
  s.require_paths = ["lib"]
  s.license       = 'MIT'

  s.add_dependency "activesupport", ["> 3.2.0","< 5.0"]
  s.add_dependency "thrift", [">= 0.9.0"]
  s.add_dependency "thor"
end
