# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "netaxept/version"

Gem::Specification.new do |s|
  s.name        = "netaxept"
  s.version     = Netaxept::VERSION
  s.authors     = ["Håkon Lerring"]
  s.email       = ["hakon@powow.no"]
  s.homepage    = ""
  s.summary     = %q{A gem for speaking to Nets Netaxept credit card payment service}
  s.description = %q{This gem simplifies the comunication with the netaxept service significantly. Right now it only supports register and sale, more is to come.}
  s.has_rdoc    = true

  s.rubyforge_project = "netaxept"
  
  s.add_dependency "httparty", "~>0.7"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "vcr"
  s.add_development_dependency "fakeweb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
