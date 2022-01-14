$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "spec_views/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "spec_views"
  spec.version     = SpecViews::VERSION
  spec.authors     = ["Sebastian Gaul"]
  spec.email       = ["sebastian.gaul@lichtbit.com"]
  spec.homepage    = "https://lichtbit.com"
  spec.summary     = "Render views from controller specs for comparision"
  spec.description = "Render views from controller specs for comparision"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.0"
  spec.add_dependency "rspec-rails", "~> 5.0"
  spec.add_dependency "haml-rails", "~> 2.0"
end
