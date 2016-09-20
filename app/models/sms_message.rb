class SmsMessage < ActiveRecord::Base
  belongs_to :receiver, :polymorphic => true
  belongs_to :resource, :polymorphic => true
  belongs_to :admin_user

  STATUS= [ "pending", "retried", "success", "failed" ]

  MODE  = [ "general", "feedback", "lottery_delivery", "manual", "verified_code" ]

  PHONE_EXP = /(^(13\d|15[^4,\D]|17[13678]|18\d)\d{8}|170[^346,\D]\d{7})$/

  scope :feedback, -> { where(mode: "feedback") }
  scope :lottery_delivery, -> { where(mode: "lottery_delivery") }
  scope :verified_code, -> { where(mode: "verified_code") }
  scope :resource_of_receiver, -> (res, rec) { where(resource: res, receiver: rec) }

  validates :phone, :content, :mode, presence: true
  validates :receiver_id, :receiver_type, presence: true, if: -> {["feedback", "lottery_delivery"].include? self.mode }
  validates_inclusion_of :status, :in => STATUS
  validates_inclusion_of :mode, :in => MODE

  def self.send_by_resource_to(target, content, resource, opts={})
    send_to(target, content, opts.merge({resource: resource}))
  end

  def self.send_to(target, content, opts={})
    message = self.new

    if target.respond_to? :mobile_number
      message.phone    = target.mobile_number
      message.receiver = target
    elsif target.is_a? String and PHONE_EXP.match(target).present?
      message.phone    = target
    else
      return false
    end

    message.status     = "pending"
    message.content    = content
    message.mode       = opts[:mode].presence || "general"
    message.resource   = opts[:resource]
    message.admin_user = opts[:admin]
    message.remark     = opts[:remark]
    if message.save!
      message.send_now
    else
      return false
    end
  end

  def send_now
    if Rails.env.development?
      res = {success: true, code: 0}
    else
      res = Emay::SendSms::to(self.phone, self.content)
    end
    if res.try(:code).to_i == 0
      self.update(status: :success)
    else
      self.update(status: :failed)
    end
  end

  def retry
    self.update(status: :retried)
    send_now
  end
end
