module Property
  module V1
    class TalkingData < Base
      resource :talking_data do
        params do
          requires :talkingdata_promotion_name, type: String
          optional :idfa, type: String
          optional :imei, type: String
          at_least_one_of :idfa, :imei
        end
        get '/login' do
          if params[:idfa]
            kol = Kol.find_by IDFA: params[:idfa]
            if kol and !kol.talkingdata_promotion_name
              kol.update_attributes(talkingdata_promotion_name: params[:talkingdata_promotion_name])
            end
          else
            kol = Kol.find_by IMEI: params[:imei]
            if kol and !kol.talkingdata_promotion_name
              kol.update_attributes(talkingdata_channel_id: params[:talkingdata_promotion_name])
            end
          end
          present :error, 0
        end
      end
    end
  end
end
