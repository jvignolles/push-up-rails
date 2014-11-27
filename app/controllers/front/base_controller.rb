class Front::BaseController < ApplicationController
  include FrontLayout # See /app/concerns/front_layout.rb

  layout "front_intern"

protected
  def nope
    return redirect_to front_home_path
  end

  def init_product_listing
    @front_kind = "products"
    scope = Product.active.ordered
    @products = scope.includes(:images).all
    @page_heading = "Nos produits"
    @page_title = "#{@page_heading} | #{app_name}"
    @page_description = "Consultez notre sélection de produits."
    key = "products"
    @breadcrumbs << { key: key, name: @page_heading, url: front_products_path }
  end
end
