# frozen_string_literal: true

module SpecViews
  class Configuration < ActiveSupport::InheritableOptions
    def self.default
      new(
        directory: 'spec/fixtures/views',
        ui_url: 'http://localhost:3000/spec_views'
      )
    end
  end
end