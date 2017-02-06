$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'version.rb'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = 'spark_plugin'
  s.version       = SparkPlugin::VERSION
  s.authors       = ['Apple Research']
  s.email         = ['apple-research@asynchrony.com']
  s.description   = 'Integrate Cisco Spark with Canvas LMS'
  s.summary       = 'Integrate Cisco Spark with Canvas LMS'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['README.md']
  s.test_files = Dir["spec_canvas/**/*"]
end
