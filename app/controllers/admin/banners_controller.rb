class Admin::BannersController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

  def strong_params
    [:active, :name, :url, :description, :button]
  end
end
