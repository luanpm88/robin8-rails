class Kol < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, allow_unconfirmed_access_for: 1.days

  has_many :identities, :dependent => :destroy

  has_many :kol_categories, :dependent => :destroy
  has_many :iptc_categories, :through => :kol_categories

  include Identities

  class EmailValidator < ActiveModel::Validator
    def validate(record)
      if record.new_record? and User.exists?(:email=>record.email)
        record.errors[:email] << "has already been taken"
      end
    end
  end

  validates_with EmailValidator

end
