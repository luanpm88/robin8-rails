module API
  module V2
    class Messages < Grape::API
      resources :messages do
        before do
          authenticate!
        end

        put 'read_all' do
          unread_message_ids = current_kol.unread_messages.collect{|t| t.id}
          unread_message_ids.each do |message_id|
            current_kol.read_messsage(message_id)
          end
          present :error, 0
        end
      end
    end
  end
end
