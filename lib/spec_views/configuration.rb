# frozen_string_literal: true

module SpecViews
  class Configuration < ActiveSupport::InheritableOptions
    def self.default
      new(
        directory: 'spec/fixtures/views',
        ui_url: 'http://localhost:3000/spec_views',
        freeze_time: '2024-02-29 00:17:42'
      )
    end
  end
end
