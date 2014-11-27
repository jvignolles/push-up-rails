class Admin::Admins::ConfirmationsController < Devise::ConfirmationsController
  include AdminAdminsLayout # See /app/concerns/admin_admins_layout.rb

  before_filter :init_view

  skip_before_filter :authenticate_admin!

private
  def after_confirmation_path_for(resource_name, resource)
    admin_home_path
  end

  def init_view
    @main_class = ["devise"]
    case params[:action].to_sym
      when :new, :create
        @page_heading = "Renvoyer l’e-mail de confirmation"
        @breadcrumbs << { name: @page_heading, url: new_admin_confirmation_path }
    end
  end
end
