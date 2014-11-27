class Admin::QuotationsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

private
  def strong_params
    %w(first_name last_name email phone description)
  end
end
