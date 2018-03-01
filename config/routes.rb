Rails.application.routes.draw do
  # resources :acts do
  #   collection { post :search, to: 'acts#index' }
  # end

  get 'home/index'
  root :to => "home#index"
  resources :acts, :conts, :webs, :adrs, :phones
end
