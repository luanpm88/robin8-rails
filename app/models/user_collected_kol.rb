class UserCollectedKol < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol
  
end
