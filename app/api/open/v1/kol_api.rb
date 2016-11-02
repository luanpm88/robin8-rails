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
          @kols = @kols.order("#{order} DESC").page(params[:page]).per_page(20)

          present :success,      true
          present :kols,         @kols, with: Open::V1::Entities::Kol::Summary
          present :total_count,  @kols.count
          present :current_page, @kols.current_page
          present :total_pages,  @kols.total_pages
        end

        desc 'Get Kol(BigV) detail by id'
        get '/:id' do
          @kol = Kol.where(id: params[:id]).take!

          present :success, true
          present :kol,     @kol, with: Open::V1::Entities::Kol::Detail
        end


        desc '获取kol数量'
        get "search_count" do
          @kols = Kol.personal_big_v

          if params[:region] and params[:region] != "全部"
            regions = params[:region].split(",").reject(&:blank?)
            cities = City.where(name: regions).map(&:name_en)

            @kols = @kols.where(app_city: cities)
          end

          if params[:tag] and params[:tag] != "全部"
            tag_params = params[:tag].split(",").reject(&:blank?)
            tags = Tag.where(name: tag_params).map(&:id)

            join_table(:kol_tags)
            @kols = @kols.where("`kol_tags`.`tag_id` IN (?)", tags)
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
