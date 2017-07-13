module Property
  module V1
    class TalkingData < Base
      resource :talking_data do
        params do
          requires :channel_id, type: String
          requires :idfa, type: String
        end
        get '/activate' do
          kol = Kol.find_by IDFA: params[:idfa]
          if kol
            kol.update_attributes(channel_id: params[:channel_id])
          end
        end
      end
    end
  end
end
