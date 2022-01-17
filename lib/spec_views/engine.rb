require 'spec_views/configuration'

module SpecViews
  class Engine < ::Rails::Engine
    config.spec_views = Configuration.default
  end
end
