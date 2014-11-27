scope '/', module: 'front', as: 'front', format: false do
  root to: 'home#index', as: 'home'
  #get '/', to: 'home#index', as: 'home', format: false
  resources :contacts, only: [:index, :new, :create]
  Editorial::KINDS.each do |kind, values|
    next if values[:token].blank?
    get "/editorials/#{values[:token]}" => 'editorials#show', as: "editorial_#{kind}", kind: kind.dup
  end
  get "/editorials/:token" => 'editorials#show', as: "editorial"
  resources :products, only: [:index, :show]
  resources :quotations, only: [:index, :new, :create]
  resources :subscriptions, only: [:index, :new, :create]
  #resources :team_members, only: [:index]
end
