# frozen_string_literal: true

require 'spec_views/configuration'

module SpecViews
  class Engine < ::Rails::Engine
    config.spec_views = Configuration.default

    initializer 'spec_views.assets.precompile' do |app|
      app.config.assets.precompile += %w[spec_views/diff.js]
    end

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
