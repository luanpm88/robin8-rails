class Kol < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  class EmailValidator < ActiveModel::Validator
    def validate(record)
      if record.new_record? and User.exists?(:email=>record.email)
        record.errors[:email] << "Email has already been taken"
      end
    end
  end

  validates_with EmailValidator

end
