# frozen_string_literal: true

require 'rails_helper'

describe SpecViews::Engine do
  it 'is an engine' do
    expect(described_class).to be < Rails::Engine
  end
end
