class KolInviteCode < ActiveRecord::Base
	belongs_to :kol
	validates :code , :kol_id , presence: true , uniqueness: true
	validates :code ,length: { is: 8 }
end
