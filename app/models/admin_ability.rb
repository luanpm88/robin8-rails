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
      can :read, Kol if admin.has_role?(:kol_read)
      can [:read, :write], Kol if admin.has_role?(:kol_write)
      can :read, Withdraw if admin.has_role?(:withdraw_read)
      can [:read, :write], Withdraw if admin.has_role?(:withdraw_write)
      can :read, HotItem if admin.has_role?(:hot_item_read)
      can [:read, :write], HotItem if admin.has_role?(:hot_item_write)
      can :read, KolAnnouncement if admin.has_role?(:kol_announcement_read)
      can [:read, :write], KolAnnouncement if admin.has_role?(:kol_announcement_write)
      can :read, HelperTag if admin.has_role?(:kol_announcement_read)
      can [:read, :write], KolAnnouncement if admin.has_role?(:kol_announcement_write)
      can :read, LotteryActivity if admin.has_role?(:lottery_activity_read)
      can [:read, :write], LotteryActivity if admin.has_role?(:lottery_activity_read)
      can :read, User if admin.has_role?(:user_read)
      can [:read, :write], User if admin.has_role?(:user_write)
      can :read, AlipayOrder if admin.has_role?(:alipay_order_read)
      can [:read, :write], AlipayOrder if admin.has_role?(:alipay_order_write)
      can :read, AlipayOrder if admin.has_role?(:alipay_order_read)
      can [:read, :write], AlipayOrder if admin.has_role?(:alipay_order_write)
      can :read, Invoice if admin.has_role?(:invoice_read)
      can [:read, :write], Invoice if admin.has_role?(:invoice_write)
      can :read, TrackUrl if admin.has_role?(:track_read)
      can [:read, :write], TrackUrl if admin.has_role?(:track_write)
    end
  end
end
