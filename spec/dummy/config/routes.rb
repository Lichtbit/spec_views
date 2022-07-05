Rails.application.routes.draw do
  resources :articles, only: %i[index new show]
end
