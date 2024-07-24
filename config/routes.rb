namespace :api do
  namespace :v1 do
    resources :companies, only: [:index]
  end
end
