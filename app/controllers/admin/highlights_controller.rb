class Admin::HighlightsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

private
  def strong_params
    %w(active name url description)
  end
end
