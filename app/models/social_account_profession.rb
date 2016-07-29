class SocialAccountProfession < ActiveRecord::Base
  belongs_to :social_account
  belongs_to :profession
end
