class KolStatus
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kol_id, type: Integer
  field :uid, type: String
  field :weibo_id, type: Integer
  field :weibo_mid, type: String
  field :weibo_idstr, type: String
  field :text, type: String
  field :source, type: String
  field :favorited, type: Boolean
  field :truncated, type: Boolean
  field :original_pic, type: String
  field :reposts_count, type: String
  field :comments_count, type: String
  field :attitudes_count, type: String
  field :visible, type: String
  field :pic_ids, type: Object
  field :created, type: DateTime



  def self.add_status(identity, statuses)
    statuses.each do |status|
      Rails.logger.info status
      exist  = KolStatus.where(:weibo_id => status['id']).first
      return if exist
      KolStatus.create!(kol_id: identity.kol_id, uid: identity.uid, weibo_id: status['id'], weibo_mid: status['mid'],
        weibo_idstr: status['id_str'], text: status['text'], source: status['source'], favorited: status['favorited'],
        truncated: status['truncated'], original_pic:status['original_pic'], reposts_count:status['reposts_count'],
        comments_count: status['comments_count'], attitudes_count: status['attitudes_count'], visible: status['visible'],
        pic_ids: status['pic_ids'], created: status['created_at']
      )
    end
  end


  def self.schedule_update_status
    if Rails.env.development?
      UpdateStatusesWorker.new.perform
    else
      UpdateStatusesWorker.perform_async
    end
  end
end
