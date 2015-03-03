class PitchesContact < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :contact
end
