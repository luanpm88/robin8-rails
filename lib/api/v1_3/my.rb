module API
  module V1_3
    class My < Grape::API
      resources :my do
        before do
          authenticate!
        end

        get 'show' do
          kol_value = KolInfluenceValue.get_score(current_kol.kol_uuid)
          present :error, 0
          tasks = RewardTask.all
          present :tasks, tasks, with: API::V2::Entities::RewardTaskEntities::Summary, kol: current_kol
          if kol_value.present?
            item_rate = kol_value.get_item_scores
            present :item_rate, item_rate, with: API::V2::Entities::KolInfluenceValueEntities::History
            present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary
          else
            present :item_rate, KolInfluenceValue.new, with: API::V2::Entities::KolInfluenceValueEntities::History
            present :kol_value, KolInfluenceValue.new, with: API::V2::Entities::KolInfluenceValueEntities::Summary
          end
        end

        desc 'get current kols lottery activities'
        params do
          optional :status, type: String, values: ["all", "executing", "finished", "win"]
        end

        get 'lottery_activities' do
          activities = current_kol.lottery_activities.available.ordered
          if !!params[:status] and params[:status] != "all"
            if params[:status] === "win"
              activities = activities.where(lucky_kol: current_kol, status: "finished")
            else
              activities = activities.where(status: params[:status])
            end
          end

          present :error, 0
          present :activities, activities, with: API::V1_3::Entities::LotteryActivityEntities::Detail, kol: current_kol
        end

        desc 'show current kols (:code) lottery activity'
        params do
          optional :status, type: String, values: ["all", "executing", "finished", "win"]
        end

        get 'lottery_activities/:code' do
          activity = LotteryActivity.available.where(code: params[:code]).take
          return {:error => 1, :detail => '无法找到此夺宝活动'} unless activity

          orders = activity.orders.where(kol: current_kol).ordered.includes(:tickets)

          present :error, 0
          present :activity, activity, with: API::V1_3::Entities::LotteryActivityEntities::Detail
          present :orders, orders, with: API::V1_3::Entities::LotteryActivityEntities::ShowOrder
          present :token_number, activity.token_number(current_kol)
        end

        desc 'show current kols address'
        get 'address' do
          address = current_kol.address!
          present :error, 0
          present :address, address, with: API::V1_3::Entities::LotteryActivityEntities::Address
        end

        desc 'show current kols address'
        params do
          optional :name, type: String
          optional :phone, type: String
          optional :region, type: String
          optional :location, type: String
        end

        put 'address' do
          address = current_kol.address!
          _params = ActionController::Parameters.new(params)
          if address.update! _params.permit(:name, :phone, :region, :location)
            present :error, 0
            present :address, address, with: API::V1_3::Entities::LotteryActivityEntities::Address
          else
            present :error, 1
            present :detail, '抱歉，更新地址失败请重试'
          end
        end
      end
    end
  end
end
