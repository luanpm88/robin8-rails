module API
  module V1_6
    class Professions < Grape::API
      resources :professions do
        before do
          authenticate!
        end

        desc '获取专业列表'
        get 'list' do
          professions  = Profession.all.order('position desc')
          present :error, 0
          present :professions, professions, with: API::V1_6::Entities::ProfessionEntities::Summary
        end
      end
    end
  end
end
