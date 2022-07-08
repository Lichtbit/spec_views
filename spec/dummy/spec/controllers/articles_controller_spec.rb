require 'rails_helper'
require 'spec_views/support'

RSpec.describe ArticlesController, type: :controller do

  describe "GET #new" do
    render "the form" do
      get :new
    end
  end

  describe "GET #index" do
    render "the listing" do
      get :index
    end
  end

  describe "GET #show" do
    render "the page" do
      get :show, params: { id: 1 }
    end
  end

end
