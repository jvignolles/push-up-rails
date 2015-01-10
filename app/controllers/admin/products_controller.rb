class Admin::ProductsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

private
  def strong_params
    %w(
      active name price resume preview description
      seo_title seo_h1 seo_description seo_keywords
    )
  end
end
