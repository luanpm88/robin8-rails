module GeTui
  module Dispatcher
    AppId = Rails.application.secrets[:getui][:app_id]
    AppKey = Rails.application.secrets[:getui][:app_key]
    MasterSecret = Rails.application.secrets[:getui][:master_secret]
    mattr_accessor :pusher

    def self.pusher
      @@pusher ||= IGeTui.pusher(AppId, AppKey, MasterSecret)
    end

    def self.push_to_single(push_message)
      return if push_message.receiver_cids.size == 0
      single_message = IGeTui::SingleMessage.new
      if push_message.template_type == 'transmission'
        single_message.data = Template.transmission_template(push_message)
      elsif push_message.template_type == 'notification'
        single_message.data = Template.notification_template(push_message)
      end
      client_cid = IGeTui::Client.new(push_message.receiver_cids[0])
      pusher.push_message_to_single(single_message, client_cid)
    end

    def self.push_to_list(push_message)
      return if push_message.receiver_cids.size == 0
      list_message = IGeTui::ListMessage.new
      if push_message.template_type == 'transmission'
        list_message.data = Template.transmission_template(push_message)
      elsif push_message.template_type == 'notification'
        list_message.data = Template.notification_template(push_message)
      end
      #获取 存储的信息 id
      list_message_content_id = @@pusher.get_content_id(list_message)
      client_cids = receiver_cids.collect{|cid| IGeTui::Client.new(cid)}
      pusher.push_message_to_list(list_message_content_id, client_cids)
    end

    def self.push_to_app(push_message)
      app_message = IGeTui::AppMessage.new
      if push_message.template_type == 'transmission'
        app_message.data = Template.transmission_template(push_message)
      elsif push_message.template_type == 'notification'
        app_message.data = Template.notification_template(push_message)
      end
      push_message.receiver_list.each{|list_key,list_value| eval("app_message.#{list_key} = #{list_value}") }
      pusher.push_message_to_app(app_message)
    end

    def self.send_message(push_message_id)
      push_message = PushMessage.find push_message_id  rescue nil
      if push_message.nil?
        Rails.logger.pusher.error "----push_message_id not found ---#{push_message_id}---"
        return
      end
      res = eval("push_to_#{push_message.receiver_type.downcase}(push_message)")
      push_message
      puts res.inspect
      # case push_message.receiver_type
      #   when 'Single'
      #    push_to_single
      #   when 'List'
      #    push_to_list
      #   when 'App'
      #    push_to_app
      # end
    end
  end
end
