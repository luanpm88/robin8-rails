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
          optional :with_message_stat, type: String, values: ['y','n']
        end
        get '/' do
          if params[:status] == 'all'
            messages = current_kol.messages.paginate(:page => params[:page], :per_page => 10 )
          elsif params[:statys] == 'unread'
            messages = current_kol.unread_messages.paginate(:page => params[:page], :per_page => 10 )
          else
            messages = current_kol.read_messages.paginate(:page => params[:page], :per_page => 10 )
          end
          present :error, 0
          present :message_stat, current_kol, with: API::V1::Entities::KolEntities::MessageStat  if params[:with_message_stat] == 'y'
          to_paginate(messages)
          present :messages, messages, with: API::V1::Entities::MessageEntities::Summary
        end

        params do
          requires :id, type: Integer
        end
        put ':id/read' do
          current_kol.read_message(params[:id])
          present :error, 0
        end
      end
    end
  end
end
