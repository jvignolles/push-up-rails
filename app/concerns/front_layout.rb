module FrontLayout
  def self.included(base)
    base.class_eval do
      helper Front::BaseHelper
      layout :set_layout
      before_filter :set_current_locale
      before_filter :check_on_hold_status
      #before_filter :authenticate_front!
      before_filter :clean_params
      before_filter :init_front_layout
    end
  end

protected
  def add_seo_fields(item)
    return unless item
    if item.seo_title.present?
      @page_title = item.seo_title
    end
    if item.seo_h1.present?
      @page_heading = item.seo_h1
    end
    if item.seo_description.present?
      @page_description = item.seo_description
    end
    if item.seo_keywords.present?
      @page_keywords = item.seo_keywords
    end
  end

  def clean_params
    [:page, :per_page].each { |attr| params.delete(attr) if params[attr].to_i <= 1 }
    true
  end

  def init_front_layout
    @configuration ||= ::Configuration.instance
    #@per_page_values = [10, 20, 30, 50, 100]
    #if (search = params[:search]).present?
    #  [:page, :per_page].each do |p|
    #    search.delete p if search[p].to_i <= 0
    #  end
    #  @per_page = search[:per_page].to_i
    #end
    #@per_page = 30 unless @per_page_values.include?(@per_page)

    # Content
    @front_kind = :default
    @display_breadcrumbs = true
    @display_quotation = true
    @active_menus = []
    @breadcrumbs = [{ key: "homepage", name: "Accueil", url: front_home_path }]
    quotation = (params[:quotation] || {})
    quotation[:from_path] ||= request.fullpath
    @quotation = Quotation.new(quotation)
    @subscription = Subscription.new(params[:subscription])
    @social_networks = {
      instagram: "Instagram",
      googleplus: "Google+",
      pinterest: "Pinterest",
      facebook: "Facebook",
      twitter: "Twitter",
    }

    # SEO
    @page_title = @configuration.seo_title
    @page_title = @configuration.app_name if @page_title.blank?
    @page_description = @configuration.seo_description
    @page_keywords = @configuration.seo_keywords
    true
  end

  def init_view
    # Should be overriden by controllers
    true
  end

  def set_current_locale
    set_locale(false)
  end

  def set_layout
    "front_intern"
  end
end
