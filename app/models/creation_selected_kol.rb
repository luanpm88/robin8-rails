class CreationSelectedKol < ActiveRecord::Base
  belongs_to :creation
  belongs_to :kol

  has_many :tenders
  
end
