# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SpecViews UI', type: :request do
  let(:fixtures) { Pathname.new(Dir.mktmpdir) }
  let(:directory) { SpecViews::Directory.new(fixtures.join('Articles_GET_articles_renders_the_listing')) }

  around do |example|
    original = Rails.configuration.spec_views.directory
    Rails.configuration.spec_views.directory = fixtures.to_s
    example.run
  ensure
    Rails.configuration.spec_views.directory = original
    FileUtils.remove_entry(fixtures)
  end

  before do
    directory.write_meta('Articles GET /articles renders the listing', :request, :html)
    directory.write_last_run(Time.current)
    directory.write_champion('<h1>Champion</h1>')
    directory.write_challenger('<h1>Challenger</h1>')
  end

  it 'lists the views' do
    get '/spec_views/views'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('CHALLENGER', 'GET')
  end

  it 'shows the compare page' do
    get "/spec_views/views/#{directory.to_param}/compare"
    expect(response).to have_http_status(:ok)
  end

  it 'shows the diff page' do
    get "/spec_views/views/#{directory.to_param}/diff"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('<script src="/spec_views/views/script.js"></script>')
  end

  describe 'diff script' do
    around do |example|
      original = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = original
    end

    it 'is served as JavaScript file despite forgery protection' do
      get '/spec_views/views/script.js'
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq 'text/javascript'
      expect(response.body).to include('JsDiff', 'function changed()')
    end
  end

  it 'responds with 404 for unknown views' do
    get '/spec_views/views/unknown/compare'
    expect(response).to have_http_status(:not_found)
  end

  it 'accepts the challenger' do
    post "/spec_views/views/#{directory.to_param}/accept"
    expect(directory.champion_html).to eq '<h1>Challenger</h1>'
    expect(directory).not_to be_challenger
  end

  context 'with identical changes in several views' do
    let(:other) { SpecViews::Directory.new(fixtures.join('Articles_GET_articles_new_renders_the_form')) }

    before do
      other.write_meta('Articles GET /articles/new renders the form', :request, :html)
      other.write_last_run(Time.current)
      [directory, other].each do |dir|
        dir.write_champion('<p>A</p>')
        dir.write_challenger('<p>B</p>')
      end
    end

    it 'shows the batch diff' do
      get '/spec_views/views/batch'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('2 Views with this Changes', '/spec_views/views/script.js')
    end

    it 'accepts the change for all views' do
      key = SpecViews::BatchDiff.new([directory, other]).biggest_change.key
      post '/spec_views/views/batch_accept', params: { key: key }
      expect([directory, other].map(&:champion_html)).to all(eq '<p>B</p>')
      expect([directory, other]).to all(satisfy { |dir| !dir.challenger? })
    end
  end

  it 'rejects the challenger' do
    post "/spec_views/views/#{directory.to_param}/reject"
    expect(directory.champion_html).to eq '<h1>Champion</h1>'
    expect(directory).not_to be_challenger
  end
end
