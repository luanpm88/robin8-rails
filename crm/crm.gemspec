$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "crm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "crm"
  s.version     = Crm::VERSION
  s.authors     = ["james"]
  s.email       = ["tardis54@163.com"]
  s.homepage    = "http://www.code.robin8.com"
  s.summary     = "Summary of Crm."
  s.description = "Description of Crm."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "mysql2"
end
