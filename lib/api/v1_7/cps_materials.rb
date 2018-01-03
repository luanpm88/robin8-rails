module API
  module V1_7
    class CpsMaterials < Grape::API
      resources :cps_materials do
        before do
          authenticate!
        end
        get 'categories' do
          categories = CpsMaterial::Categories
          present :error, 0
          present :categories, categories    #, with: API::V1_7::Entities::CpsMaterials::Category
        end

        #获取商品列表
        params do
          optional :goods_name, type: String
          optional :category_name, type: String
          optional :order_by, type: String
          optional :page, type: Integer
        end
        get '/' do
          params[:order_by] ||= 'order_overall'
          if params[:category_name].present?
            cps_materials = CpsMaterial.where("goods_name like ?", "%#{params[:goods_name]}%")
                              .where(:category => params[:category_name]).enabled.send(params[:order_by]).page(params[:page]).per_page(10)
          else
            cps_materials = CpsMaterial.where("goods_name like ?", "%#{params[:goods_name]}%")
                              .enabled.send(params[:order_by]).page(params[:page]).per_page(10)
          end
          present :error, 0
          to_paginate(cps_materials)
          present :cps_materials, cps_materials, with: API::V1_7::Entities::CpsMaterials::Summary
        end
      end
    end
  end
end
