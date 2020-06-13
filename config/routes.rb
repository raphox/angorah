Rails.application.routes.draw do
  root to: "users#index"

  resources :users do
    get 'invite', on: :member, as: :invite
  end

  get '/:id', to: 'users#show'
  get '/sign_in/:user_id', to: 'login#sign_in', as: :sign_in

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
