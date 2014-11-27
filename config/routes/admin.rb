devise_for :admins,
  path: '/admin/',
  format: false,
  controllers: {
    confirmations: 'admin/admins/confirmations', # DEV NOTE: route "show" to remove
    sessions:      'admin/admins/sessions',
    #registrations: 'admin/admin/registrations', # DEV NOTE: routes created manually inside scope
    passwords:     'admin/admins/passwords',
    unlocks:       'admin/admins/unlocks',
  },
  skip: [:registrations],
  path_names: {
    password: 'password-lost',
  }

#scope '/', module: 'admin', as: 'admin', format: false do
namespace 'admin', format: false do
  root to: 'home#index', as: 'home'
  namespace :admins do
    resources :admins, except: [:show] do
      has_image_routes
    end
  end
  resources :banners, except: [:show] do
    has_image_routes
    has_reorder_routes
  end
  resources :configurations, only: [:index, :edit, :update] do
    has_image_routes
  end
  resources :contacts, only: [:index, :show, :destroy]
  resources :countries, except: [:show]
  resources :editorials, except: [:show] do
    has_image_routes
    has_reorder_routes
  end
  resources :highlights, except: [:show] do
    has_image_routes
    has_reorder_routes
  end
  resources :products, except: [:show] do
    has_image_routes
    has_reorder_routes
  end
  resources :quotations, only: [:index, :show, :destroy]
  resources :subscriptions, only: [:index, :destroy]
  #resources :team_members, except: [:show] do
  #  has_image_routes
  #  has_reorder_routes
  #end

  get '/email-layout' => 'home#email_layout', as: 'email_layout', format: false # DEV NOTE: test only
end

#constraint = lambda { |request| !!request.session['warden.user.admin.key'] }
#constraints constraint do
#  mount Sidekiq::Web => '/admin/sidekiq/frame'
#end
