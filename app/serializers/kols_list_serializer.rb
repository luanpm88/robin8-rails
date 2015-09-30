class KolsListSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :kols_count
end
