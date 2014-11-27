class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end

  def has_image_routes
    resources :images, :controller => :images, :only => [:create, :update, :destroy] do
      collection do
        #get :create_remote # Only required for S3 without Ajax (to allow GET callback)
        get :list
        put :reorder
        get :upload_form
      end
      member do
        match :assist, via: [:get, :post]
        put :copy
        put :highlight
      end
    end
  end

  def has_likes_routes
    resources :likes, :controller => :likes, :only => [:create, :destroy]
  end

  def has_reorder_routes
    collection do
      get :reorder
      put :reorder
    end
  end
end
