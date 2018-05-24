# coding: utf-8
module API
  module V2_0
    class Promotions < Grape::API
      resources :promotions do
        before do
          authenticate!
        end

        get '/' do
	        present error: 0, promotion: Promotion.valid.try(:to_hash)
        end

      end
    end
  end
end