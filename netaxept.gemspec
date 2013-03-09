# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "netaxept/version"

Gem::Specification.new do |s|
  s.name        = "netaxept"
  s.version     = Netaxept::VERSION
  s.authors     = ["Håkon Lerring", "Rolf Bjaanes"]
  s.email       = ["hakon@powow.no", "rolf@powow.no"]
  s.homepage    = "https://github.com/Hakon/netaxept"
  s.summary     = %q{A gem for speaking to Nets Netaxept credit card payment service}
  s.description = %q{Very thin client for communicating with Netaxept credit card payment gateway.}
  s.has_rdoc    = true

  s.rubyforge_project = "netaxept"

  s.add_dependency "rest-client", "1.6.7"
  s.add_dependency "nokogiri", "1.5.6"
  
  s.add_development_dependency "rake", "10.0.3"
  s.add_development_dependency "rspec", "2.13.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
