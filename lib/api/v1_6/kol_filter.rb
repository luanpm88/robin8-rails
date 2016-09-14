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
            cities = params[:region].split(',').collect { |name| ::City.where("name like '#{name}%'").first.name_en }
            @kols = @kols.ransack({app_city_in: cities}).result
          end
          if params[:tags] && params[:tags] != '全部'
            tags = params[:tags].split(',').collect { |name| ::Tag.get_name_by_label(name) }
            @kols = @kols.ransack({kol_tags_tag_id_in: tags}).result
          end

          if params[:age] && params[:age] != '全部'
            min_age = params[:age].split(',').map(&:to_i).first
            max_age = params[:age].split(',').map(&:to_i).last
            @kols = @kols.ransack({age_in: Range.new(min_age, max_age)}).result
          end

          if params[:gender] && params[:gender] != '全部'
            @kols = @kols.ransack({gender_eq: params[:gender].to_i}).result
          end

          present error: 0
          present count: @kols.count
        end
      end
    end
  end
end
