module Open
  module V1
    class KolAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
        request_limit!
      end

      resource :kols do
        desc 'Get KOL(BigV) list'
        params do
          optional :page,  type: Integer
          optional :tag,   type: String
          optional :name,  type: String
          optional :order, type: String, values: ['hot', 'createtime']
        end
        get '/' do
          @kols = Kol.where(kol_role: ['mcn_big_v', 'big_v'])

          if params[:name].present?
            @kols = @kols.where("`kols`.`name` LIKE ?", "%#{params[:name]}%")
          end

          if params[:tag].present?
            tag   = Tag.where(name: params[:tag]).take!
            @kols = @kols.joins(:kol_tags => [:tag]).where("`kol_tags`.`tag_id` = #{tag.id}")
          else
            @kols = @kols.includes(:kol_tags => [:tag])
          end

          order = params[:order] == "hot" ? "is_hot" : "created_at"
          @kols = @kols.order("is_hot DESC").page(params[:page]).per_page(20)

          present :success,      true
          present :kols,         @kols, with: Open::V1::Entities::Kol::Summary
          present :total_count,  @kols.count
          present :current_page, @kols.current_page
          present :total_pages,  @kols.total_pages
        end

        desc 'Get Kol(BigV) detail by id'
        get ':id/show' do
          @kol = Kol.where(id: params[:id]).take!

          present :success, true
          present :kol,     @kol, with: Open::V1::Entities::Kol::Detail
        end


        desc '获取kol数量'
        get "search_count" do
          @kols = Kol.active

          if params[:region] and params[:region] != "全部"
            city_name_ens = []
            params[:region].split(",").each do |region|
              city = City.where("name like '#{region[0,2]}%'").first  rescue nil
              if city
                city_name_ens << city.name_en
              else
                province = Province.where("name like '#{region[0,2]}%'").first  rescue nil
                if province
                  province.cities.each do |city|
                    city_name_ens << city.name_en
                  end
                end
              end
            end

            @kols = @kols.where(app_city: city_name_ens)
          end

          if params[:tags] and params[:tags] != "全部"
            tag_params = params[:tags].split(",").reject(&:blank?)
            tag_ids = Tag.where(label: tag_params).map(&:id)

            @kols = @kols.joins(:kol_tags).where("`kol_tags`.`tag_id` IN (?)", tag_ids)
          end

          if params[:age] && params[:age] != '全部'
            min_age = params[:age].split(',').map(&:to_i).first
            max_age = params[:age].split(',').map(&:to_i).last
            @kols = @kols.ransack({age_in: Range.new(min_age, max_age)}).result
          end

          if params[:gender] && params[:gender] != '全部'
            @kols = @kols.ransack({gender_eq: params[:gender].to_i}).result
          end

          present :success, true
          present :count, @kols.distinct.count
        end
      end
    end
  end
end
