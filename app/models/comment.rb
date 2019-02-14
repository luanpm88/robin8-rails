class Comment < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :resource_from, :polymorphic => true
  belongs_to :resource_to, :polymorphic => true

  has_many :sub_comments, class_name: "Comment", foreign_key: :parent_id
  
end
