# frozen_string_literal: true

# The UI writes and deletes fixture files, so it must never be reachable in production.
return unless Rails.env.local?

Rails.application.routes.draw do
  namespace :spec_views do
    root to: redirect('spec_views/views')

    resources :views, only: %i[index show] do
      collection do
        get :batch
        get :script
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
