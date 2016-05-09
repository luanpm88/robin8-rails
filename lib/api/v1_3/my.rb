module API
  module V1_3
    class My < Grape::API
      resources :my do
        before do
          authenticate!
        end

        get 'show' do
          kol_value = KolInfluenceValue.get_score(current_kol.kol_uuid)
          item_rate = kol_value.get_item_scores
          tasks = RewardTask.all
          present :item_rate, item_rate, with: API::V2::Entities::KolInfluenceValueEntities::History
          present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary
          present :tasks, tasks, with: API::V2::Entities::RewardTaskEntities::Summary, kol: current_kol
        end

      end
    end
  end
end
