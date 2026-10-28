# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SpecViews routes' do
  let(:routes_file) { SpecViews::Engine.root.join('config/routes.rb') }

  it 'are drawn in local environments' do
    expect(Rails.application.routes.url_helpers.spec_views_views_path).to eq '/spec_views/views'
  end

  it 'are not drawn outside of local environments' do
    allow(Rails.env).to receive(:local?).and_return(false)
    expect(Rails.application.routes).not_to receive(:draw)
    load routes_file
  end
end
