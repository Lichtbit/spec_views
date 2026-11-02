# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# Boot the dummy app that matches the Rails version of the current bundle,
# e.g. spec/dummy_8_1 for Rails 8.1.x.
require 'bundler/setup'
rails_version = Gem.loaded_specs.fetch('railties').version.segments.first(2).join('_')
require_relative "dummy_#{rails_version}/config/environment"

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

require 'spec_views/support'

RSpec.configure do |config|
  config.use_active_record = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
