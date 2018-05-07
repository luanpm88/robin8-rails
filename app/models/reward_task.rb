class RewardTask < ActiveRecord::Base
  default_scope  -> {order("position asc")}

  CheckIn = 'check_in'
  CompleteInfo = 'complete_info'
  InviteFriend = 'invite_friend'
  FavorableComment = 'favorable_comment'
  FriendGains = 'percentage_on_friend'
  # 新手任务(首次分享活动¥0.5, 首次查看活动示例¥0.5, 首次上传活动截图¥1.0)
  NewbieTasks = {
							  	first_share_campaign: 0.5,
							  	first_check_example: 0.5,
							  	first_upload_invite: 1.0
							  }

  scope :invite_friend, -> {where(:task_type => InviteFriend).first}

end
