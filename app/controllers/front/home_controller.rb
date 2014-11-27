# encoding: utf-8
class Front::HomeController < Front::BaseController
  def index
    @front_kind = :homepage
    @active_menus << :homepage
    @banners = Banner.active.ordered.limit(3).includes(:images)
    @highlights = Highlight.active.ordered.limit(6).includes(:images)
    @page_heading = @configuration.baseline
    @editorial = Editorial.find_by_kind(:homepage)
    add_seo_fields @editorial
  end
end

