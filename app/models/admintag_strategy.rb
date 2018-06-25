# admintag_strategy 为第三方合作公司(geometry, 高校体育...)配置各种奖励金额以及活动单价比例，师傅抽成，管理员抽成等等
class AdmintagStrategy < ActiveRecord::Base
	# register_bounty:            default 0   注册奖励
	# invite_bounty:              default 2   成功邀请好友奖励
	# invites_max_count:          default 10  每日最多邀请奖励次数
	# invite_bounty_for_admin:    default 0   基于geometry业务要求，当成功注册的用户，他的管理员会得到2块钱的奖励
	# first_task_bounty:          default 0   首次活动奖励，成功生成一条campaign_invite
	# unit_price_rate_for_kol:    default 1   活动单价比例，默认为Rate，不过也可以在原来的Rate上再作调整 计算公式为 campaign.per_action_budget * Rate * unti_price_rate
	# unit_price_rate_for_admin:  default 0   当这个值大于0时，管理员会得其以下成员活动收益的别外一部分
	# master_income_rate:         default 0   geometry为0,其他为kol默认收益的5%

  # actual_per_action_budget: amount paid to KOL (currently 60% of per_action_budget)
  # actual_per_action_budget * unit_price_rate_for_kol
	# 默认活动单价用户抽60%， 活动收益师傅额外得徒弟的5%(系统发放，不抽用户的钱)，成功邀请一个好友奖励2元
	InitHash = 	{
							  register_bounty:            0,
								invite_bounty:              2,
								invites_max_count:          10,
								invite_bounty_for_admin:    0,
								first_task_bounty:          0,
								unit_price_rate_for_kol:    1,
								unit_price_rate_for_admin:  0,
								master_income_rate:         0.05,
							}

	belongs_to :admintag

	mount_uploader :logo, ImageUploader

	def owner_sets
		{
			register_bounty: 				 		register_bounty,
			invite_bounty: 					 		invite_bounty,
			invites_max_count:          invites_max_count,
			invite_bounty_for_admin: 		invite_bounty_for_admin,
			first_task_bounty: 					first_task_bounty,
			unit_price_rate_for_kol: 		unit_price_rate_for_kol,
			unit_price_rate_for_admin: 	unit_price_rate_for_admin,
			master_income_rate: 				master_income_rate
		}
	end

end
