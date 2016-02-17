module GeTui
  class Template
    class <<  self
      # setPushInfo(actionLocKey, badge, message, sound, payload, locKey, locArgs, launchImage)
      def notification_template(push_message,options = {})
        template = IGeTui::NotificationTemplate.new
        set_template_base_info(template)
        #apns 通知
        template.set_push_info("open", 4, "message", "")
        template
      end

      def transmission_template(push_message,options = {})
        # Notice: content should be string.
        content = push_message.template_content.stringify_keys.to_s.gsub("=>", ":")
        template = IGeTui::TransmissionTemplate.new
        template.transmission_content = content
        puts template.transmission_content
        # template.set_push_info("test", 1, "test1", "")
        template
      end

       def set_template_base_info(template)
         template.logo = 'push.png'
         template.logo_url = 'http://www.igetui.com/wp-content/uploads/2013/08/logo_getui1.png'
         template.title = '测试标题'
         template.text = '测试文本'
       end
    end
  end
end
