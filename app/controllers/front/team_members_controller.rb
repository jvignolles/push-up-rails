class Front::TeamMembersController < Front::BaseController
  def index
    @team_members = TeamMember.active.ordered.includes(:images)
    @front_kind = "team_members"
    @page_heading = "L’équipe"
  end
end
