class CreationTarget < ActiveRecord::Base
  belongs_to :targetable, polymorphic: true
  belongs_to :creation
end
