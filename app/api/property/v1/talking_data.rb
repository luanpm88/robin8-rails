module Property
  module V1
    class TalkingData < Base
      resource :talking_data do
        params do
          requires :channel_id, type: String
          requires :idfa, type: String
        end
        get '/login' do
          kol = Kol.find_by IDFA: params[:idfa]
          if kol and !kol.talkingdata_channel_id
            kol.update_attributes(talkingdata_channel_id: params[:channel_id])
          end
          present :error, 0
        end
      end
    end
  end
end
