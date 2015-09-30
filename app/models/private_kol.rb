class PrivateKol < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol
end
