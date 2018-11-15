# coding: utf-8
module API
  module V2_1
    class Votes < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        desc '我的爱豆列表'
        params do
        	requires :page, type: Integer
        end
        get 'my_idois' do
        	my_idois = Kol.joins(:voter_ships).where('voter_ships.voter_id=?', current_kol.id).order(is_hot: :desc)

        	list = paginate(Kaminari.paginate_array(my_idois))
          present :error, 0
          present :list, list, with: API::V2_1::Entities::KolEntities::Brief
        end

        desc '我的粉丝列表'
        params do
        	requires :page, type: Integer
        end
        get 'my_voters' do
        	list = paginate(Kaminari.paginate_array(current_kol.voters))
          present :error, 0
          present :list, list, with: API::V2_1::Entities::KolEntities::Brief
        end

			end
		end
	end
end
