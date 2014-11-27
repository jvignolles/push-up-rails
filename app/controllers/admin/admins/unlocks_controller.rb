class Admin::Admins::UnlocksController < Devise::UnlocksController
  include AdminAdminsLayout # See /app/concerns/admin_admins_layout.rb

  before_filter :init_view

  def sign_in_root_path(resource_or_scope)
    admin_home_path
  end

  #def sign_in_and_redirect(resource_or_scope)
  #  admin_home_path
  #end

  def after_sign_in_path_for(resource_or_scope)
    admin_home_path
  end

  def after_sign_out_path_for(resource_or_scope)
    admin_home_path
  end

  def new
    super
    if admin_signed_in?
      return redirect_to admin_home_path
    end
    flash.keys.each do |key|
      if error_key = t("devise.failure").detect { |k, v| flash[key] == v }
        flash[:admin_auth_error] = flash[key]
        flash[:display_admin_confirmation_instructions] = true if "unconfirmed" == error_key[0].to_s
      else
        flash[key] = flash[key]
      end
    end
  end

private
  def init_view
    @main_class = ["devise"]
    case params[:action].to_sym
      when :new, :create
        @page_heading = "Déverrouiller votre compte"
        @breadcrumbs << { name: t("devise.shared.unlock"), url: new_admin_unlock_path }
    end
  end
end
