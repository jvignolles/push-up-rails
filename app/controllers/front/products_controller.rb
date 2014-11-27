class Front::ProductsController < Front::BaseController
  def index
    init_product_listing
  end

  def show
    @product = Product.find_by_id(params[:id])
    if !@product || !@product.active
      if @product && current_admin
        flash[:warning] = "Attention, cette page est actuellement inactive : elle n’est pas affichée aux internautes"
      else
        flash[:alert] = "Cette page n’existe plus"
        return redirect_to(front_home_path)
      end
    end
    # TODO: this redirection skips params (but they aren't currently used). CARE!
    correct_url = front_product_path(id: @product)
    if request.original_fullpath != correct_url
      # DEV NOTE: SEO safe, avoid duplicate URLs if product is renamed.
      return redirect_to(correct_url, status: 301)
    end
    @quotation.product_id ||= @product.id
    @page_heading = @product.name
    @front_kind = "product"
    @geocoding_assets = true
    @page_title = "#{@page_heading} | #{app_name}"
    @breadcrumbs << { key: "products-#{@product.id}", name: @page_heading, url: front_product_path(id: @product) }
    add_seo_fields @product
  end
end
