module Brand
  module V2
    class MessagesAPI < Base
      include Grape::Kaminari

      group do
        before do
          authenticate!
        end

        resource :messages do

          desc 'new message count' #获取未读站内信数量
          get 'new_message_count' do
            present error: 0, new_message_count: Message.where(receiver: current_user, is_read: false).count
          end

          desc 'messages list'
          get '/' do 
            @messages = paginate(Kaminari.paginate_array(Message.where(receiver: current_user).order(is_read: :desc)))

            present @messages, with: Entities::Message
          end

          desc 'update message is read'
          params do
            requires :id, type: Integer
          end
          post 'is_read' do
            @message = Message.find params[:id]

            return {error: 1, detail:  I18n.t("brand_api.errors.messages.not_found")} unless @message

            present error: 0, alert: I18n.t('brand_api.success.messages.update_succeed'), new_message_count: Message.where(receiver: current_user, is_read: false).count if @message.is_read

            if @message.update_attributes(is_read: true)
              present error: 0, alert: I18n.t('brand_api.success.messages.update_succeed'), new_message_count: Message.where(receiver: current_user, is_read: false).count
            else
              return {error: 1, detail: I18n.t('brand_api.errors.messages.update_failed')}
            end

          end


        end
      end
    end
  end
end