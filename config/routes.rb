Rails.application.routes.draw do
  namespace :spec_views do
    root to: redirect('spec_views/views')

    resources :views, only: %i[index show] do
      collection do
        delete :destroy_outdated
        post :accept_all
      end
      member do
        get :compare
        get :preview
        post :accept
        post :reject
      end
    end
  end
end
