class SocialAccountTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :kol
end
