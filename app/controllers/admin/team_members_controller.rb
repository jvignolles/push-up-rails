class Admin::TeamMembersController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

private
  def strong_params
    %w(active civility first_name last_name description)
  end
end
