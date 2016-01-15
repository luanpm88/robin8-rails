class DiscoverRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kol_id, type: Integer
  field :discover_id, type: Integer

  validates :kol_id, presence: true
  validates :discover_id, presence: true
end
