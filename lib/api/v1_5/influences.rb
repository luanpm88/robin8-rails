module API
  module V1_5
    class Influences < Grape::API
      resources :influences do
        before do
          authenticate!
        end

        params do
          requires :kol_uuid, type: String
        end
        get '/' do
          kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
          item_rate, item_score = kol_value.get_item_scores
          if current_kol
            # KolContact.update_joined_kols(current_kol.id)
            joined_contacts = KolContact.joined.where(:kol_id => current_kol.id)
            contacts_count = KolContact.order_by_exist.where(:kol_id => current_kol.id).count
          else
            # TmpKolContact.update_joined_kols(params[:kol_uuid])
            joined_contacts = TmpKolContact.joined.where(:kol_uuid => params[:kol_uuid])
            contacts_count = TmpKolContact.order_by_exist.where(:kol_uuid => params[:kol_uuid]).count
          end
          rank_index = joined_contacts.where("influence_score > '#{kol_value.influence_score}'").count + 1
          present :error, 0
          present :identities, current_kol.get_uniq_identities, with: API::V1::Entities::IdentityEntities::Summary
          present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary, kol: current_kol
          present :diff_score, KolInfluenceValue.diff_score(params[:kol_uuid], current_kol.try(:id), kol_value)
          present :item_rate, item_rate, with: API::V2::Entities::KolInfluenceValueEntities::ItemRate
          present :item_score, item_score, with: API::V2::Entities::KolInfluenceValueEntities::ItemScore
          present :history, KolInfluenceValueHistory.get_auto_history(params[:kol_uuid],  current_kol.try(:id))
          present :contact_count, contacts_count
          present :rank_index, rank_index
          present :foward_read_count, (current_kol.article_actions.forward.collect{|t| t.redis_click.value}.sum  rescue 0)
        end

        params do
          requires :kol_uuid, type: String
        end
        get '/my_analysis' do
           weibo_identity = current_kol.identities.provider('weibo').order('score desc').first rescue nil
           if weibo_identity.nil?
             weibo_identity_status = 'no_bind'
           else
             state, statuses = Weibo.get_status(weibo_identity)
             if state == false
               weibo_identity_status = 'had_expired'
             else
               res = NlpService.get_analyze_content(statuses)
               weibo_identity_status = 'active'
               categories = res['category']
               wordclouds = res["wordcloud"].collect{|t| t['text']}
             end
           end
           present :error, 0
           present :weibo_identity_status, weibo_identity_status
           present :categories, categories, with: API::V1_5::Entities::NlpServiceEntities::Category
           present :wordclouds, wordclouds
        end
      end
    end
  end
end
