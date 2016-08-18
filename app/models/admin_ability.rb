class AdminAbility
  include CanCan::Ability

  def initialize(admin)
    if admin.has_role? :admin
      can :manage, :all
    else
      can :read, Campaign if admin.has_role?(:campaign_read)
      can [:read, :write], Campaign if admin.has_role?(:campaign_write)
      can :read, CampaignInvite if admin.has_role?(:campaign_invite_read)
      can [:read, :write], CampaignInvite if admin.has_role?(:campaign_invite_write)
      can [:read], Kol if admin.has_role?(:kol_read)
      can [:read, :write], Kol if admin.has_role?(:kol_write)
    end
  end
end
