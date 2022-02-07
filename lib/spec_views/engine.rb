require 'spec_views/configuration'

module SpecViews
  class Engine < ::Rails::Engine
    config.spec_views = Configuration.default

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
