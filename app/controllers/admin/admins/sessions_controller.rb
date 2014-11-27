class Admin::Admins::SessionsController < Devise::SessionsController
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

  def create
    super
    flash.delete(:notice)
  end

  #def auth_failure
  #  flash[:admin_auth_error] = t('devise.failure.invalid')
  #  redirect_to request.referer
  #end

private
  def init_view
    @main_class = ["devise"]
    case params[:action].to_sym
      when :new, :create
        @page_heading = "Bonjour ! Merci de vous identifier…"
        @breadcrumbs << { name: t("devise.shared.sign_in"), url: new_admin_session_path }
    end
  end
end
