class CampaignsSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :deadline, :budget, :created_at, :updated_at, :user
end
