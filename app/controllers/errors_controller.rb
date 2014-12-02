class ErrorsController < ApplicationController
  include AdminLayout # See /app/concerns/admin_layout.rb
  layout "error"

  #skip_before_filter :set_current_locale
  skip_before_filter :check_on_hold_status
  skip_before_filter :authenticate_admin!

  def show
    @page_heading = "Cette page n’existe pas…"
    @page_title = "Oops…"
    @breadcrumbs = [{ key: :home, name: "Accueil", url: front_home_path }]
    render status_code.to_s, :status => status_code
  end

protected
  def status_code
    params[:code] || 500
  end
end
