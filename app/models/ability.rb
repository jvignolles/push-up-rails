class Ability
  include CanCan::Ability

  def initialize(admin)
    admin ||= Admin.new # guest user (not logged in)
    if admin.admin?
      can :manage, :all
      return
    end
    can [:index], Admin
    can [:update], Admin, id: admin.id
    can do |action, subject_class, subject|
      ![Admin, Configuration].include?(subject_class)
    end
  end
end
