class PushMessage < ActiveRecord::Base
  include GeTui::Dispatcher

  belongs_to :item, :polymorphic => true

  serialize :receiver_ids, Array
  serialize :receiver_cids, Array
  serialize :template_content, Hash
  serialize :receiver_list, Hash
  serialize :result_serial, Hash
  after_commit :async_send_to_client, :on => :create
  # template_type  'transmission', 'notification'       =>   'transmission'


  def self.transmission_template_content(message)
    # content = {:action => message.message_type, :title => message.title, :sender => message.sender, :name => message.name}
    content = {:action => message.message_type,  :sender => message.sender, :name => message.title}
    if message.message_type == 'income'
      receiver = message.receiver
      new_income =  receiver.new_income
      new_income = rand(100) if Rails.env.development? && new_income == 0
      content.merge!({:new_income =>  new_income, :unread_message_count => receiver.unread_messages.count})
    end
    content
  end

  def self.create_message_push(message , device_tokens = nil)
    #to one
    push_message = nil
    if message.message_type == 'income'  || message.message_type == 'screenshot_passed' ||  message.message_type == 'screenshot_rejected' || message.message_type == 'common'
      receiver = message.receiver
      push_message = self.new(:receiver_type => 'Single', :template_type => 'transmission', :receiver_ids => [receiver.id],
                              :title => message.title, :receiver_cids => [receiver.device_token] )
      push_message.template_content = transmission_template_content(message)
    elsif message.message_type == 'announcement'
      push_message = self.new(:receiver_type => 'All', :template_type => 'transmission', :title => message.title,
                              :receiver_list => {:app_id_list => [GeTui::Dispatcher::AppId] })
      push_message.template_content = transmission_template_content(message)
    elsif message.message_type == 'notice'
      if message.receiver_type == "All" 
        device_tokens =  Kol.where(" amount >= 50 ").collect{|t| t.device_token}.uniq
        device_tokens.in_groups_of(1000,false){|group_device_tokens|
          push_message = self.new(:template_type => 'transmission', :template_content => transmission_template_content(message),
                                  :title => message.title, :receiver_type => 'List', :receiver_cids => group_device_tokens )
          push_message.message_id = message.id
          push_message.save
          sleep 0.5
        }
        return #only save
      end
    elsif message.message_type == 'campaign'
      push_message = self.new(:template_type => 'transmission', :template_content => transmission_template_content(message),
                              :title => message.title)
      if message.receiver_type == 'All'
        push_message.receiver_type = 'App'
        push_message.receiver_list = {:app_id_list => [GeTui::Dispatcher::AppId] }
      elsif message.receiver_type == 'Kol'
        receiver = message.receiver
        push_message.receiver_type = 'Single'
        push_message.receiver_ids = [receiver.id]
        push_message.receiver_cids = [receiver.device_token]
      elsif message.receiver_type == 'List'
        device_tokens ||=  Kol.where(:id => message.receiver_ids ).collect{|t| t.device_token}.uniq
        device_tokens.in_groups_of(1000,false){|group_device_tokens|
          push_message = self.new(:template_type => 'transmission', :template_content => transmission_template_content(message),:title => message.title, :receiver_type => 'List', :receiver_cids => group_device_tokens )
          push_message.message_id = message.id
          push_message.item_id = message.item_id
          push_message.item_type = message.item_type
          push_message.save
          sleep 0.5
        }
        return #only save
      end
    # to list
    elsif message.message_type == 'remind_upload'
      push_message = self.new(:template_type => 'transmission', :template_content => transmission_template_content(message),
                              :title => message.title)
      receivers = Kol.where(:id => message.receiver_ids)
      push_message.receiver_type = 'List'
      push_message.receiver_ids = receivers.collect{|t| t.id }
      push_message.receiver_cids = receivers.collect{|t| t.device_token}

    elsif message.message_type == 'notification'
      push_message = self.new(:receiver_type => 'All', :template_type => 'notification', :title => message.title,
                              :receiver_list => {:app_id_list => [GeTui::Dispatcher::AppId] })
      push_message.template_content = transmission_template_content(message)
    end

    #统一保存
    if push_message
      push_message.message_id = message.id
      push_message.item_id = message.item_id
      push_message.item_type = message.item_type
      push_message.save
    end
  end

  Robin8Logo = "http://7xozqe.com2.z0.glb.qiniucdn.com/robin8_log-2016-3-30.jpg"
  def self.push_campaign_message
    executing_campaigns = Campaign.where(:status => 'executing', :end_apply_check => false)
    Rails.logger.pusher.info "=======push_campaign_message======"
    return if  executing_campaigns.size == 0
    should_push_kol_ids = []
    executing_campaigns.each {|t| should_push_kol_ids += t.get_kol_ids }
    push_kol_ids = should_push_kol_ids.uniq
    # 个推限定list 最大为1000
    title =  '你还有未参与的活动，速去转发赚钱！'
    device_tokens =  Kol.where(:id => push_kol_ids ).collect{|t| t.device_token}.uniq
    template_content = {:action => 'common', :title => title, :sender => 'robin8', :name => '新活动消息'}
    device_tokens.in_groups_of(1000,false){|group_device_tokens|
      push_message = self.new(:template_type => 'transmission', :template_content => template_content, :title => title,
                              :receiver_type => 'List', :receiver_cids => group_device_tokens )
      push_message.save
      sleep 0.5
    }
  end

  #Notice receivers 长度不能超过1000
  # receivers:接受kols,  title: 主要内容, name: 通知栏标题,  item: 关联对象
  def self.push_common_message(receivers,  title, name = "你有一条新的消息", item = nil)
    content = {:action => 'common', :title => title, :sender => 'robin8', :name => name}
    push_message = self.new(:template_type => 'transmission', :template_content => content,
                            :title => title, :receiver_type => 'List' )
    push_message.receiver_ids = receivers.collect{|t| t.id }
    push_message.receiver_cids = receivers.collect{|t| t.device_token}.uniq
    push_message.item =  item if item.present?
    push_message.save
  end

  def self.push_check_to_author(receiver, title)
    push_message = self.new(:receiver_type => 'Single', :template_type => 'transmission', :receiver_ids => [receiver.id],
                            :title => title, :receiver_cids => [receiver.device_token] )
    push_message.template_content = {:action => 'common', :title => title, :sender => 'robin8', :name => '文章审核结果'}
    push_message.save
  end

  def async_send_to_client
    puts "====async_send_to_client"
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
