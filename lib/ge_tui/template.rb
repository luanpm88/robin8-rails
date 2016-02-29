module GeTui
  module Template
    def self.notification_template(push_message,options = {})
      template = IGeTui::NotificationTemplate.new
      # push_message.template_content.stringify_keys.each{|key,value| template.instance_variable_set("@#{key}",value)}
      #apns 通知
      # setPushInfo(actionLocKey, badge, message, sound, payload, locKey, locArgs, launchImage)
      template.set_push_info("open", 1, push_message.title, "")   if (push_message.template_content[:action] == 'campaign' rescue false)
      template
    end

    def self.transmission_template(push_message,options = {})
      # Notice: content should be string.
      content = push_message.template_content.stringify_keys.to_s.gsub(":", "").gsub("=>", ":")
      puts content
      template = IGeTui::TransmissionTemplate.new
      template.transmission_content = content
      template.set_push_info("open", 1, push_message.title, "")     if (push_message.template_content[:action] == 'campaign' rescue false)
      puts template.transmission_content
      template
    end

     # def set_template_base_info(push_message)
     #   template.logo = 'push.png'
     #   template.logo_url = 'http://www.igetui.com/wp-content/uploads/2013/08/logo_getui1.png'
     #   template.title = '测试标题'
     #   template.text = '测试文本'
     # end
  end
end
