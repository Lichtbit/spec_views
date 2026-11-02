# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'spec_views/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'spec_views'
  spec.version     = SpecViews::VERSION
  spec.authors     = ['Sebastian Gaul']
  spec.email       = ['sebastian.gaul@lichtbit.com']
  spec.homepage    = 'https://github.com/Lichtbit/spec_views'
  spec.summary     = 'Render views from controller specs for comparision'
  spec.description = 'Render views from controller specs for comparision'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.2'

  spec.metadata = {
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['{app,config,lib}/**/*', 'MIT-LICENSE', 'README.md', 'CHANGELOG.md']

  spec.add_dependency 'actionpack', '>= 7.2', '< 9'
  spec.add_dependency 'activesupport', '>= 7.2', '< 9'
  spec.add_dependency 'diff-lcs', '>= 1.5', '< 3'
  spec.add_dependency 'railties', '>= 7.2', '< 9'
  spec.add_dependency 'rspec-rails', '>= 7.0', '< 9'
end
