# frozen_string_literal: true

module SpecViews
  class Configuration < ActiveSupport::InheritableOptions
    def self.default
      new(
        directory: 'spec/fixtures/views'
      )
    end
  end
end