class AdminAbility
  include CanCan::Ability

  def initialize(admin)
    if admin.has_any_role? :super_admin
      can :manage, :all
    else
      can [:read, :update], AdminUser if admin.has_role?(:super_admin)
      can :read, Campaign if admin.has_role?(:campaign_read)
      can [:read, :update], Campaign if admin.has_role?(:campaign_update)
      can :read, CampaignInvite if admin.has_role?(:campaign_invite_read)
      can [:read, :update], CampaignInvite if admin.has_role?(:campaign_invite_update)
      can :read, Kol if admin.has_role?(:kol_read)
      can [:read, :update], Kol if admin.has_role?(:kol_update)
      can :read, Withdraw if admin.has_role?(:withdraw_read)
      can [:read, :update], Withdraw if admin.has_role?(:withdraw_update)
      can :read, HotItem if admin.has_role?(:hot_item_read)
      can [:read, :update], HotItem if admin.has_role?(:hot_item_update)
      can :read, KolAnnouncement if admin.has_role?(:kol_announcement_read)
      can [:read, :update], KolAnnouncement if admin.has_role?(:kol_announcement_update)
      can :read, HelperTag if admin.has_role?(:helper_tag_read)
      can [:read, :update], HelperTag if admin.has_role?(:helper_tag_update)
      can :read, LotteryActivity if admin.has_role?(:lottery_activity_read)
      can [:read, :update], LotteryActivity if admin.has_role?(:lottery_activity_update)
      can :read, User if admin.has_role?(:user_read)
      can [:read, :update], User if admin.has_role?(:user_update)
      can :read, AlipayOrder if admin.has_role?(:alipay_order_read)
      can [:read, :update], AlipayOrder if admin.has_role?(:alipay_order_update)
      can :read, AlipayOrder if admin.has_role?(:alipay_order_read)
      can [:read, :update], AlipayOrder if admin.has_role?(:alipay_order_update)
      can :read, Invoice if admin.has_role?(:invoice_read)
      can [:read, :update], Invoice if admin.has_role?(:invoice_update)
      can :read, Feedback if admin.has_role?(:feedback_read)
      can [:read, :update], Feedback if admin.has_role?(:feedback_update)
      can :read, TrackUrl if admin.has_role?(:track_read)
      can [:read, :update], TrackUrl if admin.has_role?(:track_update)
      can :read, StasticData if admin.has_role?(:statistic_data_read)
      can [:read, :update], StasticData if admin.has_role?(:statistic_data_update)
      can [:read], AppUpgrade if admin.has_role?(:app_upgrade_read)
      can [:read, :update], AppUpgrade if admin.has_role?(:app_upgrade_update)
    end
  end
end
