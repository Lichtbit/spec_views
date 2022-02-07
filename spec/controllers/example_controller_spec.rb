require 'rails_helper'
require 'spec_views/support'

RSpec.describe ArticlesController, type: :controller do

  describe "GET #show" do
    render "the page" do
      get :show, params: { id: 1 }
    end
  end

end
