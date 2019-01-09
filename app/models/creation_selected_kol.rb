class CreationSelectedKol < ActiveRecord::Base
  belongs_to :creation
  belongs_to :kol
end
