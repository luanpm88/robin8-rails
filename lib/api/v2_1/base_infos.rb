# coding: utf-8
module API
  module V2_1
    class BaseInfos < Grape::API
      resources :base_infos do
        before do
          # authenticate!
        end

        get '/' do
          # Rails.cache.delete('api:v2_1:base_infos')
          cache(key: "api:v2_1:base_infos") do
            present :error, 0
            present :circles_list,    Circle.all, with: API::V2_1::Entities::BaseInfoEntities::Circle
            present :terraces_list,   Terrace.all, with: API::V2_1::Entities::BaseInfoEntities::Terrace
            present :ages_list,       Creator::AgeRanges.to_a
            present :weibo_auth_list, WeiboAccount::AuthTypes.to_a
          end
        end
      end
    end
  end
end