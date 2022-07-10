require 'rails_helper'
require 'spec_views/support'

RSpec.describe ArticlesController, type: :controller do
  describe "GET #new" do
    it_renders "the form" do
      get :new
    end

    render_views
    it 'renders the form' do
      get :new
      expect(response).to match_html_fixture
    end
  end

  describe "GET #index" do
    render_views
    it "renders the listing" do
      get :index
      expect(response).not_to match_html_fixture
    end
  end

  describe "GET #show" do
    render_views
    it "renders the page" do
      get :show, params: { id: 1 }
      expect(response).not_to match_html_fixture
    end
  end

  describe "GET #download", focus: true do
    render_views
    it 'sends PDF one' do
      get :download, params: { id: 'one', format: :pdf }
      expect(response).to match_pdf_fixture
    end

    it 'sends PDF two' do
      get :download, params: { id: 'two', format: :pdf }
      expect(response).not_to match_pdf_fixture
    end

    it 'sends PDF three' do
      get :download, params: { id: 'three', format: :pdf }
      expect(response).not_to match_pdf_fixture
    end
  end
end
