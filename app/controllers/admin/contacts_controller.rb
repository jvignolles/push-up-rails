class Admin::ContactsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

private
  def strong_params
    %w(name email phone subject description)
  end
end
