class Admin::Admins::PasswordsController < Devise::PasswordsController
  include AdminAdminsLayout # See /app/concerns/admin_admins_layout.rb

  before_filter :init_view

  def after_sign_in_path_for(resource_or_scope)
    admin_home_path
  end

private
  def init_view
    @main_class = ["devise"]
    case params[:action].to_sym
      when :new, :create
        @page_heading = t("devise.shared.forgot_password")
        @breadcrumbs << { name: @page_heading, url: edit_admin_password_path }
      when :edit, :update
        @page_heading = "Nouveau mot de passe"
        @breadcrumbs << { name: @page_heading, url: edit_admin_password_path }
    end
  end
end
