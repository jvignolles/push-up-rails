class Front::QuotationsController < Front::BaseController
  def index
    return redirect_to(new_front_quotation_path)
  end

  def new
    @quotation = Quotation.new(params[:quotation])
    init_view
  end

  def create
    @quotation = Quotation.new(params[:quotation])
    if @quotation.save
      Notifier.quotation({
        :quotation => @quotation,
      }).deliver # delay # SIDEKIQ
      flash[:notice] = "Votre demande a bien été envoyée"
      url = new_front_quotation_path
      url = @quotation.from_url if @quotation.from_path.present?
      return redirect_to(url)
    end
    init_view
    render :new
  end

private
  def init_view
    @front_kind = "quotations"
    @page_heading = "Demander un devis"
    @page_title = "#{@page_heading} | #{app_name}"
    @breadcrumbs << { key: "quotations", name: "Demander un devis", url: new_front_quotation_path }
    @display_quotation = false
  end
end
