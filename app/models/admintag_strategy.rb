# admintag_strategy 为第三方合作公司(geometry, 高校体育...)配置各种奖励金额以及活动单价比例，师傅抽成，管理员抽成等等
class AdmintagStrategy < ActiveRecord::Base

	# 默认活动单价用户抽60%， 活动收益师傅额外得徒弟的5%(系统发放，不抽用户的钱)，成功邀请一个好友奖励2元
	Rate 							= 0.6
	MasterIncomeRate 	= 0.05
	InviteBounty 			= 2.0

	# register_bounty:            default 0   注册奖励
	# invite_bounty:              default 2   成功邀请好友奖励
	# invite_bounty_for_admin:    default 0   基于geometry业务要求，当成功注册的用户，他的管理员会得到2块钱的奖励
	# first_task_bounty:          default 0   首次活动奖励，成功生成一条campaign_invite
	# unit_price_rate_for_kol:    default 1   活动单价比例，默认为Rate，不过也可以在原来的Rate上再作调整 计算公式为 campaign.per_action_budget * Rate * unti_price_rate
	# unit_price_rate_for_admin:  default 0   当这个值大于0时，管理员会得其以下成员活动收益的别外一部分
	# master_income_rate:         default 0   geometry为0,其他为kol默认收益的5%

	belongs_to :admintag

end