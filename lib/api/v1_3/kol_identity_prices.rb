module API
  module V1_3
    class KolIdentityPrices < Grape::API
      resources :kol_identity_prices do
        before do
          authenticate!
        end

        get 'list'  do
          kol_identity_prices = current_kol.kol_identity_prices
          present :error, 0
          present :kol_identity_prices, kol_identity_prices, with: API::V1_3::Entities::KolIdentityPriceEntities::Summary
        end

        params do
          requires :provider, type: String, values: ['public_wechat', 'wechat', 'weibo']
        end
        get 'price_item' do
          identity_price = current_kol.kol_identity_prices.find_or_create_by(:provider => params[:provider])
          present :kol_identity_price, identity_price, with: API::V1_3::Entities::KolIdentityPriceEntities::Summary
        end

        params do
          requires :provider, type: String, values: ['public_wechat', 'wechat', 'weibo']
          optional :name, type: String
          optional :follower_count, type: String
          optional :belong_field, type: String
          optional :headline_price, type: String
          optional :second_price, type: String
          optional :single_price, type: String
        end
        put 'set_price' do
          identity_price = current_kol.kol_identity_prices.find_or_create_by(:provider => params[:provider])
          identity_price.update_columns(name: params[:name], follower_count: params[:follower_count],
                                        belong_field: params[:belong_field], headline_price: params[:headline_price],
                                        second_price: params[:second_price], single_price: params[:single_price])
          present :error, 0
          present :kol_identity_price, identity_price, with: API::V1_3::Entities::KolIdentityPriceEntities::Summary
        end
      end
    end
  end
end
