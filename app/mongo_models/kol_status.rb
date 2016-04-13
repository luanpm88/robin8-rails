class KolStatus
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kol_id, type: Integer
  field :uid, type: String
  field :weibo_id, type: Integer
  field :weibo_mid, type: String
  field :weibo_idstr, type: String
  field :text, type: Text
  field :source, type: String
  field :favorited, type: Boolean
  field :truncated, type: Boolean
  field :original_pic, type: String
  field :reposts_count, type: String
  field :comments_count, type: String
  field :attitudes_count, type: String
  field :visible, type: String
  field :pic_ids, type: Text
  field :ad, type: Text


end
