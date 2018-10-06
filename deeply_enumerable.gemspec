$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "deeply_enumerable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "deeply_enumerable"
  s.version     = DeeplyEnumerable::VERSION
  s.authors     = ["chaunce"]
  s.email       = ["chaunce.slc@gmail.com"]
  s.homepage    = "https://github.com/chaunce/deeply_enumerable"
  s.summary     = "recusrive support for enumerable operations"
  s.description = "recusrive support for enumerable operations"
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rspec"
end
