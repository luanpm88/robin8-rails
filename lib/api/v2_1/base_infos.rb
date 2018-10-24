# coding: utf-8
module API
  module V2_1
    class BaseInfos < Grape::API
      resources :base_infos do
        before do
          authenticate!
        end

        get 'circles' do
        end

        get 'terraces' do
        end

      end
    end
  end
end