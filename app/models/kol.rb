class Kol < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, allow_unconfirmed_access_for: 1.days

  has_many :identities, :dependent => :destroy

  has_many :kol_categories, :dependent => :destroy
  has_many :iptc_categories, :through => :kol_categories
  has_many :campaign_invite
  has_many :campaign, :through => :campaign_invites
  has_many :articles
  has_many :article_comments, as: :sender

  include Models::Identities
  extend Models::Oauth

  class EmailValidator < ActiveModel::Validator
    def validate(record)
      if record.new_record? and User.exists?(:email=>record.email)
        record.errors[:email] << "has already been taken"
      end
    end
  end

  validates_with EmailValidator

end
