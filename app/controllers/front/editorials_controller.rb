# encoding: utf-8
class Front::EditorialsController < Front::BaseController
  def show
    kind = params[:kind].present? && Editorial::KINDS[params[:kind]].present? ? params[:kind] : nil
    @editorial = if kind
      Editorial.find_by_kind(kind)
    else
      Editorial.find_by_id(params[:token])
    end
    if !@editorial || !@editorial.active
      if @editorial && current_admin
        flash[:warning] = "Attention, cette page est actuellement inactive : elle n’est pas affichée aux internautes"
      else
        flash[:alert] = "Cette page n’existe plus"
        return redirect_to(front_home_path)
      end
    end
    @page_heading = @editorial.name
    @front_kind = "editorial"
    url = kind ? send("front_editorial_#{kind}_path") : front_editorial_path(@editorial)
    @breadcrumbs << { key: "editorials", name: @page_heading, url: url }
    add_seo_fields @editorial
  end
end

