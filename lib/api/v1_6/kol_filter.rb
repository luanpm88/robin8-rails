module API
  module V1_6
    class KolFilter < Grape::API
      resources :kol_filter do
        before do
          authenticate!
        end
        desc 'return kol count'
        get '/kol_count' do
          @kols = Kol.active.personal_big_v
          if params[:region] && params[:region] != "全部"
            @kols = @kols.ransack({app_city_in: ['nanjing', 'shanghai']}).result
          end
          if params[:tags] && params[:tags] != '全部'
            @kols = @kols.ransack({kol_tags_tag_id_in: [1, 2]}).result
          end

          present error: 0
          present count: @kols.count
        end
      end
    end
  end
end
