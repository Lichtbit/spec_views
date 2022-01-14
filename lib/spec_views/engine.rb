require 'spec_views/configuration'

module SpecViews
  class Engine < ::Rails::Engine
    config.spec_views = Configuration.default

    initializer 'configure.rspec' do |app|
      if Rails.env.test? && Object.const_defined?('RSpec')
        require 'spec_views/support'
        
        RSpec.configure do |config|
          config.include Support
        end
      end
    end
  end
end
