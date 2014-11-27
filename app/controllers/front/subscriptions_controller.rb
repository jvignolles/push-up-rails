class Front::SubscriptionsController < Front::BaseController
  def index
    return redirect_to(new_front_subscription_path)
  end

  def new
    @subscription = Subscription.new(params[:subscription])
    init_view
  end

  def create
    p = params[:subscription] || {}
    @subscription = Subscription.new(p)
    if @subscription.save || (p[:email].present? && Subscription.where(kind: "newsletter", email: p[:email]))
      flash[:notice] = "Votre inscription à la newsletter a bien été enregistrée"
      return redirect_to(front_home_path)
    end
    init_view
    render :new
  end

private
  def init_view
    @front_kind = "subscriptions"
    @page_heading = "Newsletter #{app_name}"
    @page_title = "Inscription newsletter | #{app_name}"
    @breadcrumbs << { key: "subscriptions", name: "Inscription newsletter", url: new_front_subscription_path }
    @display_quotation = false
  end
end
