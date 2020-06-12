Rails.application.routes.draw do
  root to: "users#index"

  resources :users do
    get 'invite', on: :member, as: :invite
  end

  get '/:id', to: 'users#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
