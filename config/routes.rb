# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :spec_views do
    root to: redirect('spec_views/views')

    resources :views, only: %i[index show] do
      collection do
        get :batch
        delete :destroy_outdated
        post :accept_all
        post :reject_all
        post :batch_accept
      end
      member do
        get :compare
        get :diff
        get :preview
        post :accept
        post :reject
      end
    end
  end
end
