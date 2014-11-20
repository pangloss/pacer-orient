# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pacer-orient/version"

Gem::Specification.new do |s|
  s.name        = "pacer-orient"
  s.version     = Pacer::Orient::VERSION
  s.platform    = 'java'
  s.authors     = ["Darrick Wiebe"]
  s.email       = ["dw@xnlogic.com"]
  s.homepage    = "http://orientechnologies.com"
  s.summary     = %q{Orient jars and related code for Pacer}
  s.description = s.summary

  s.add_dependency 'pacer', Pacer::Orient::PACER_REQ
  s.add_dependency "lock_jar", "~> 0.10.1"

  s.rubyforge_project = "pacer-orient"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
