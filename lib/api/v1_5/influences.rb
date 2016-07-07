module API
  module V1_5
    class Influences < Grape::API
      resources :influences do
        params do
          requires :kol_uuid, type: String
        end
        get '/' do
          kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
          item_rate, item_score = kol_value.get_item_scores
          if current_kol
            KolContact.update_joined_kols(current_kol.id)
            joined_contacts = KolContact.joined.where(:kol_id => current_kol.id)
            contacts = KolContact.order_by_exist.where(:kol_id => current_kol.id)
          else
            TmpKolContact.update_joined_kols(params[:kol_uuid])
            joined_contacts = TmpKolContact.joined.where(:kol_uuid => params[:kol_uuid])
            contacts = TmpKolContact.order_by_exist.where(:kol_uuid => params[:kol_uuid])
          end
          rank_index = joined_contacts.where("influence_score > '#{kol_value.influence_score}'").count + 1
          present :error, 0
          present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary, kol: current_kol
          present :diff_score, KolInfluenceValue.diff_score(params[:kol_uuid], current_kol.try(:id), kol_value)
          present :item_rate, item_rate, with: API::V2::Entities::KolInfluenceValueEntities::ItemRate
          present :item_score, item_score, with: API::V2::Entities::KolInfluenceValueEntities::ItemScore
          present :history, KolInfluenceValueHistory.get_auto_history(params[:kol_uuid],  current_kol.try(:id))
          present :contact_count, contacts.size
          present :rank_index, rank_index
        end
      end
    end
  end
end
