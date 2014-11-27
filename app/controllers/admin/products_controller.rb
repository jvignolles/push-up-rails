class Admin::ProductsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

  def tabs
    h = super.to_a
    h.insert(1, [:locations, { text: "Itinéraire et lieux", icon: "globe" }])
    h.insert(1, [:options,   { text: "Options",             icon: "plus-sign" }])
    h.insert(1, [:steps,     { text: "Programme",           icon: "calendar" }])
    h.to_h
  end

  def update
    p = params[model_name.tableize.singularize.to_sym] || {}
    @item.attributes = p
    if @item.save
      flash[:notice] = "#{translate_model_name.mb_chars.capitalize} #{formatted_item_name}modifié(e)"
      #=== Override part
      if (ids = (params[:product] || {})[:map_location_ids]).present?
        # Force reorder
        LocationsProduct.reorder_locations(@item.id, ids.reject(&:blank?))
      end
      #=== /Override part
      return redirect_to(send("edit_#{namespaces_}#{model_name.tableize.singularize}_path", { id: @item.id }))
    end
    init_view
    render :edit
  end

private
  def strong_params
    %w(active name price resume preview description seo_title seo_h1 seo_description seo_keywords)
  end
end
