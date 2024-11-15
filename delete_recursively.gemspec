# encoding: utf-8

dir = File.expand_path('..', __FILE__)
require File.join(dir, 'lib', 'delete_recursively', 'version')

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'delete_recursively'
  s.version     = DeleteRecursively::VERSION
  s.license     = 'MIT'

  s.summary     = 'Delete ActiveRecords efficiently'
  s.description = 'Adds a new :dependent option for ActiveRecord associations '\
                  'that recursively deletes all dependent records without '\
                  'instantiating them.'

  s.authors     = ['Janosch Müller']
  s.email       = 'janosch84@gmail.com'
  s.homepage    = 'https://github.com/jaynetics/delete_recursively'

  s.files       = Dir['lib/**/*.rb']

  s.required_ruby_version = '>= 2.1.1'

  s.add_dependency 'activerecord', '>= 4.1.14'

  s.add_development_dependency 'appraisal', '~> 2.4'
  s.add_development_dependency 'rails', '>= 4.1.14'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rspec-rails', '~> 7.1'
  s.add_development_dependency 'simplecov-cobertura', '~> 2.1'
  s.add_development_dependency 'sqlite3', '~> 2.1'
end
