class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    alias_action :create, :read, :update, :destroy, :to => :crud
    # can :crud, Campaign, :user_id => user.id  这么写也是对的
    can :crud, Campaign do |campaign|
      campaign.user == user
    end

    can :read, CampaignInvite do |campaign_invite|
      campaign_invite.campaign.user == user
    end

    can :read, CampaignApply do |campaign_apply|
      campaign_apply.campaign.user == user
    end


    # can :power_handle, Project do |project|
    #   project.human_owner == user
    # end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
