module API
  module V1
    class Messages < Grape::API
      resources :messages do
        before do
          authenticate!
        end

        params do
          requires :status, type: String, values: ['all', 'unread', 'read']
          optional :page, type: Integer
        end
        get '/' do
          messages = current_kol.messages.send(params[:status]).page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(messages)
          present :messages, messages, with: API::V1::Entities::MessageEntities::Summary
        end


        params do
          requires :id, type: Integer
        end
        put ':id/read' do
          message = current_kol.messages.find(params[:id])   rescue nil
          if message
            message.read
            present :error, 0
            present :message, message, with: API::V1::Entities::MessageEntities::Summary
          else
            return error_403!({error: 1, detail: '你查看的消息不存在' })
          end
        end
      end
    end
  end
end
