class PushMessage < ActiveRecord::Base
  serialize :receiver_ids, Array
  serialize :reciver_cids, Array
  serialize :template_content, Hash
  serialize :receiver_list, Hash
  serialize :result_serial, Hash

  after_commit :send_to_client

  # template_type  'transmission', 'notification'

  def  message_template_content(message)
    {
      :action => message.message_type,
      :title => message.title,
      :logo_url => message.logo_url,
      :desc => message.desc,
      :url => message.url,
      :item_id => message.item_id
    }
  end

  def self.create_message_push(message)
    if message.message_type == 'income'
      receiver = message.receiver
      push_message = self.new(:receiver_type => 'single', :template_type => 'transmission', :receiver_ids => [receiver.id], :receiver_cids => [receiver.device_token])
      push_message.template_content = message_template_content
      push_message.save
    end
  end

  def send_to_client
    if Rails.env.development?
      PusherWorker.new.perform(self.id)
    else
      PusherWorker.perform_async(self.id)
    end
  end



  # t.string :receiver_type
  # t.string :receiver_ids
  # t.text :reciver_cids
  # t.string :receiver_list
  # t.string :template_type
  # t.text :template_content
  # t.boolean :is_offline, :default => true
  # t.integer :offline_expire_time, :default => 1000 * 3600 * 12
  # t.string :result
  # t.text :result_serial
  # t.string :details
  # t.string :task_id

end
