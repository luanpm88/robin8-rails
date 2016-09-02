module Open
  module V1
    class KolAPI < Base
      include Grape::Kaminari
      # before do
      #   authenticate!
      # end

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
          present :data,         @kols, with: Open::V1::Entities::Kol::Summary
          present :total_count,  @kols.count
          present :current_page, @kols.current_page
          present :total_pages,  @kols.total_pages
        end

        desc 'Get Kol(BigV) detail by id'
        get '/:id' do
          @kol = Kol.where(id: params[:id]).take!

          present :success, true
          present :data, @kol, with: Open::V1::Entities::Kol::Detail
        end
      end
    end
  end
end