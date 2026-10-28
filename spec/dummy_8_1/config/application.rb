# frozen_string_literal: true

require_relative 'boot'

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'propshaft'
require 'spec_views'

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.1

    # Controllers, views, routes and environments are shared by all dummy apps.
    shared = File.expand_path('../../dummy_shared', __dir__)
    %w[app/controllers app/mailers app/views config/environments config/routes.rb].each do |path|
      config.paths[path] << File.join(shared, path)
    end
    config.paths['public'] = File.join(shared, 'public')

    config.spec_views.directory = File.expand_path('../../fixtures/views', __dir__)
  end
end
