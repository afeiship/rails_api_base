Rails.application.routes.draw do
  mount RailsApiBase::Engine => "/rails_api_base"

  # API resources
  namespace :api do
    resources :posts do
      resources :comments
    end
    resources :users do
      resources :posts
    end
  end
end
