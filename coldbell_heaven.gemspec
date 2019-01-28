$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "coldbell_heaven/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "coldbell_heaven"
  s.version     = ColdbellHeaven::VERSION
  s.authors     = ["Rei Hakurei"]
  s.email       = ["reimu_after_marisa@yahoo.com"]
  s.homepage    = "https://bloom-juery.net"
  s.summary     = "a database for certain idolmaster game"
  s.description = "game db"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.6"
  s.add_dependency 'romajify'
  s.add_dependency 'safe_attributes'
  s.add_dependency 'csv'

  s.add_development_dependency "sqlite3"
end
