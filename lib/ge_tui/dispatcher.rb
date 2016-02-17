module GeTui
  class Dispatcher
    class << self
      attr_accessor :pusher

      def pusher
        @@pusher = IGeTui.pusher(@app_id, @app_key, @master_secret)
      end

      def single_notification(push_message)
        single_message = IGeTui::SingleMessage.new
        single_message.data = notification_template
        ret = @pusher.push_message_to_single(single_message, @client_1)
      end

      def app_notification(push_message)

      end


      def single_transmission(push_message)
        return if push_message.receiver_cids.size == 0
        client_cid = IGeTui::Client.new(push_message.receiver_cids[0])
        single_message = IGeTui::SingleMessage.new
        single_message.data = Getui::Template.transmission_template(push_message)
        pusher.push_message_to_single(single_message, client_cid)
      end

      def app_transmission(push_message)

      end

      def send(push_message_id)
        push_message = PushMessage.find push_message_id  rescue nil
        if push_message.nil?
          Rails.logger.pusher.error "----push_message_id not found ---#{push_message_id}---"
          return
        end
        case push_message.template_type
          when 'transmission'
            if push_message.receiver_type == 'single'
              single_notification  push_message
            else
              app_notification push_message
            end
          when 'notification'
            if push_message.receiver_type == 'single'
              single_notification  push_message
            else
              app_notification push_message
            end
        end
      end
    end
  end
end
