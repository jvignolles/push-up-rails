class Admin::CountriesController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

private
  def strong_params
    %w(active code name)
  end

  def init_view
    super
    if [:new, :create, :edit, :update].include? params[:action].to_sym
      scope = Destination.active.alphabetical
      @destinations = [["", ""]] + scope.map { |e| [e.name, e.id.to_s] }
    end
  end
end
