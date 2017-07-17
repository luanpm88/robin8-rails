module Property
  module V1
    class TalkingData < Base
      resource :talking_data do
        params do
          requires :channel_id, type: String
          optional :idfa, type: String
          optional :imei, type: String
          at_least_one_of :idfa, :imei
          # requires :idfa, type: String
        end
        get '/login' do
          if params[:idfa]
            kol = Kol.find_by IDFA: params[:idfa]
            if kol and !kol.talkingdata_channel_id
              kol.update_attributes(talkingdata_channel_id: params[:channel_id])
            end
          else
            kol = Kol.find_by IMEI: params[:imei]
            if kol and !kol.talkingdata_channel_id
              kol.update_attributes(talkingdata_channel_id: params[:channel_id])
            end
          end
          present :error, 0
        end
      end
    end
  end
end
