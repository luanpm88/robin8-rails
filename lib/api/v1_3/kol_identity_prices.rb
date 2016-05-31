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
          optional :name, type: String
          optional :follower_count, type: Integer
          optional :belong_field, type: String
          # optional :headline_price, type: Float
          # optional :second_price, type: Float
          # optional :single_price, type: Float
        end
        put 'set_price' do
          return error_403!({error: 1, detail: '头条价格必须大于0数值，或置为空'}) if params[:headline_price].present? &&  params[:headline_price].to_f <= '0'
          return error_403!({error: 1, detail: '次条价格必须大于0数值，或置为空'}) if params[:second_price].present? &&  params[:second_price].to_f <= '0'
          return error_403!({error: 1, detail: '单条价格必须大于0数值，或置为空'}) if params[:single_price].present? &&  params[:single_price].to_f <= '0'
          identity_price = current_kol.kol_identity_prices.find_or_create_by(:provider => params[:provider])
          identity_price.update_columns(name: params[:name], follower_count: params[:follower_count],
                                        belong_field: params[:belong_field], headline_price: params[:headline_price],
                                        second_price: params[:second_price],single_price: params[:single_price])
          present :error, 0
          present :kol_identity_price, identity_price, with: API::V1_3::Entities::KolIdentityPriceEntities::Summary
        end
      end
    end
  end
end
