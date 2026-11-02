# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  describe 'GET /articles/new' do
    it_renders 'the form' do
      get new_article_path
    end

    it 'renders the form' do
      get new_article_path
      expect(response).to match_html_fixture
    end
  end

  describe 'GET /articles' do
    it 'renders the listing' do
      get articles_path
      expect(response).not_to match_html_fixture
    end
  end

  describe 'GET /articles/:id' do
    it 'renders the page' do
      get article_path(1)
      expect(response).not_to match_html_fixture
    end
  end

  describe 'GET /articles/:id/download' do
    it 'sends PDF one' do
      get download_article_path(:one, format: :pdf)
      expect(response).to match_pdf_fixture
    end

    it 'sends PDF two' do
      get download_article_path(:two, format: :pdf)
      expect(response).not_to match_pdf_fixture
    end

    it 'sends PDF three' do
      get download_article_path(:three, format: :pdf)
      expect(response).not_to match_pdf_fixture
    end
  end
end
