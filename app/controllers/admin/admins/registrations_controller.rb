class Admin::Admins::RegistrationsController < Devise::RegistrationsController
  include AdminAdminsLayout # See /app/concerns/admin_admins_layout.rb

  before_filter :init_view

  def after_sign_in_path_for(resource)
    admins_path
  end

  def after_sign_up_path_for(resource)
    admins_path
  end

  # If admins have to be confirm their e-mail
  def after_inactive_sign_up_path_for(resource_or_scope)
    admins_registration_complete_path(admin_id: resource_or_scope.id)
  end

  def new
    resource = build_resource({})
    if session[:customer_id].present? && (customer = Customer.find_by_id(session[:customer_id]))
      [:civility, :first_name, :last_name, :email, :mobile].each do |field|
        resource.send("#{field}=", customer.send(field))
      end
    end
    respond_with resource
  end

  def create
    build_resource

    # Custom part before save
    customer = session[:customer_id].present? && Customer.find_by_id(session[:customer_id])
    if customer
      # Populate other Admin's fields if available
      [:phone, :birthday].each do |field|
        resource.send("#{field}=", customer.send(field)) if customer.send(field).present?
      end
      if resource.email == customer.email && !resource.confirmed?
        resource.skip_confirmation!
      end
    end

    # Devise
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end

      # Custom part after save
      if customer
        # Update Customer with current Admin
        p = { admin_id: resource.id }
        p[:authorized_by_admin] = "authorized" if "authorized" != customer.authorized_by_admin
        customer.update_attributes(p)
        session.delete(:customer_id)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # Don't want the following methods
  def edit;    raise ActionController::RoutingError.new('Not Found'); end
  def update;  raise ActionController::RoutingError.new('Not Found'); end
  def destroy; raise ActionController::RoutingError.new('Not Found'); end
  def cancel;  raise ActionController::RoutingError.new('Not Found'); end

private
  def init_view
    case params[:action].to_sym
      when :new, :create
        @page_heading = "Créez votre compte"
        @breadcrumbs << { name: t("devise.shared.sign_up"), url: new_admin_registration_path }
        @main_class = ["devise"]
    end
  end
end
