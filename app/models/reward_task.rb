class RewardTask < ActiveRecord::Base
  default_scope  -> {order("position asc")}

  CheckIn = 'check_in'
  CompleteInfo = 'complete_info'
  InviteFriend = 'invite_friend'
  FavorableComment = 'favorable_comment'
  Friends = %w(invite_friend percentage_on_friend)

  scope :invite_friend, -> {where(:task_type => InviteFriend).first}

end
