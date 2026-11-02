# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpecViews::Support, type: :request do
  around do |example|
    original = Rails.configuration.spec_views.freeze_time
    example.run
  ensure
    Rails.configuration.spec_views.freeze_time = original
  end

  it 'freezes the time by default' do
    expect(Time.current).to eq Time.zone.local(2024, 2, 29, 0, 17, 42)
  end

  context 'with a custom time' do
    before(:context) { Rails.configuration.spec_views.freeze_time = Time.zone.local(2030, 1, 2, 3, 4, 5) }

    it 'freezes the time at the configured time' do
      expect(Time.current).to eq Time.zone.local(2030, 1, 2, 3, 4, 5)
    end
  end

  context 'when disabled' do
    before(:context) { Rails.configuration.spec_views.freeze_time = false }

    it 'does not freeze the time' do
      expect(Time.current.year).to be >= 2026
    end
  end
end
