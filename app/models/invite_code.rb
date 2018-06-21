class InviteCode < ActiveRecord::Base

  validates :code , presence: true
  validates :code , presence: {message: "邀请码不能为空"},length: {is: 6 , message: "邀请码长度必须为6位"} , uniqueness: {message: "邀请码已存在"}
  validates :invite_type ,  inclusion: {in: ["admintag" ,"club_leader","club_member"]}
  validates :invite_value , presence: {message: "标签名/社团名不能为空"} ,uniqueness: {message: "标签名/社团名已存在"} 

  InviteType = {'admintag' =>  'Admintag' , 'club_leader' => '社团Leader' , 'club_member' => '社团成员' , 'invite_friend' => '邀请好友'}

  after_create :gen_admintag

  def gen_admintag
  	Admintag.find_or_create_by(tag: invite_value) if invite_type == 'admintag'
  end
end
