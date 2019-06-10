class RegisteredInvitation < ActiveRecord::Base
  attr_accessor :sms_code

  STATUSES = %w(pending completed)

  belongs_to :inviter, inverse_of: :registered_invitations, class_name: "Kol"
  belongs_to :invitee, inverse_of: :registered_invitation, class_name: "Kol"
  validates_uniqueness_of :mobile_number, :message => "您已经接受过邀请了"
  #validates_format_of :mobile_number, :with => /((13\d|15[^4,\D]|17[13678]|18\d)\d{8}|170[^346,\D]\d{7})/ , :message => "无效的手机号"
  validates_format_of :mobile_number, :with => /[0-9\+]{8,12}/ , :message => "Invalid mobile number!"

  scope :pending,   -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :recent, ->(_start,_end){ where(updated_at: _start.beginning_of_day.._end.end_of_day) }
end