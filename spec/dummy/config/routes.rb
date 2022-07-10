Rails.application.routes.draw do
  resources :articles, only: %i[index new show] do
    member do
      get :download
    end
  end
end
