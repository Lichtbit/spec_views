require 'rails_helper'
require 'spec_views/support'

RSpec.describe ArticlesController, type: :controller do

  describe "GET #new" do
    it_renders "the form" do
      get :new
    end
  end

  describe "GET #index" do
    it_renders "the listing" do
      get :index
    end
  end

  describe "GET #show" do
    it_renders "the page" do
      get :show, params: { id: 1 }
    end
  end

end
