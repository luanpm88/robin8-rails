class ShareByEmail
  include ActiveModel::Model

  attr_accessor :subject, :body, :sender, :reciever
  
  validates_presence_of :subject, :body, :sender, :reciever
  validates :sender, email_format: true
  validates :reciever, email_format: true

  def initialize(user, args = {})
    @user = user
    unless args.blank?
      self.subject   = args[:subject]
      self.body      = args[:body]
      self.sender    = args[:sender]
      self.reciever  = args[:reciever]
    end
  end
  
  def persisted?
    false
  end

  def submit
    if valid?
      true
    else
      false
    end
  end
end
