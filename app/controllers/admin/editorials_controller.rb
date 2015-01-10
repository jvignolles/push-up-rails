class Admin::EditorialsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

  def new
    p = params[model_name.tableize.singularize.to_sym] || {}
    @item = model_name.constantize.new(p)
    #=== Customization:
    if params[:kind].present?
      @item.kind = params[:kind]
      @item.name = I18n.t("editorials.names.#{@item.kind}")
      @item.in_lateral_menu = (e = Editorial::KINDS[params[:kind]]).present? ? e[:menu] : true
    end
    #=== End of customization
    init_view
  end

  def search(search = {})
    p = params[:search] || {}
    if p.present?
      scoped = model_name.constantize.adm_for_text(p[:text]).ordered
      # TODO: add specific scopes
      # TODO: add inclues (ex: .includes(:images))
      scoped.paginate(page: params[:page], per_page: @per_page)
    else
      scoped = model_name.constantize.ordered
      kinds = scoped.map(&:kind).reject(&:blank?)
      (Editorial::KINDS.map { |k, v| k } - kinds).each do |kind|
        scoped << { kind: kind, name: I18n.t("editorials.names.#{kind}") }
      end
      scoped
    end
  end

private
  def strong_params
    %w(
      active in_lateral_menu name kind text1 text2 text3
      seo_title seo_h1 seo_description seo_keywords
    )
  end
end
