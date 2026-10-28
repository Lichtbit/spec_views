# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

namespace :spec do
  desc 'Run the specs against every Rails version in gemfiles/'
  task :all do
    Dir['gemfiles/rails_*.gemfile'].each do |gemfile|
      puts "== #{gemfile}"
      Bundler.with_unbundled_env do
        sh({ 'BUNDLE_GEMFILE' => gemfile }, 'bundle install --quiet && bundle exec rspec')
      end
    end
  end
end

task default: %i[spec rubocop]
