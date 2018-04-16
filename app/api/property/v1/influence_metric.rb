module Property
  module V1
    class InfluenceMetric < Base
      resource :influence_metric do
        params do
          requires :api_token, type: String
          requires :provider, type: String
          requires :provider_uid
          requires :influence_score
          requires :avg_posts
          requires :avg_comments
          requires :avg_likes
          requires :industries
        end

        post 'save_influence' do
          api_token_password = 'only-heroes-can-create-influence'
          unless params[:api_token] == api_token_password
            present :error, 1
            present :error_message, 'Incorrect api_token'
            return
          end
          Rails.logger.influence_score.info "-----#{params}-----"
          # begin
          # identity = ::Identity.where(provider: params[:provider], uid: params[:provider_uid]).first
          # kol = identity.kol
          # rescue
          #   status 400
          #   present :error, 1
          #   present :error_message, "KOL or kol identity not found"
          #   return
          # end

          identity = ::Identity.where(provider: params[:provider], uid: params[:provider_uid]).first rescue nil
          kol = identity.kol rescue nil

          if kol and identity
            begin
              ActiveRecord::Base.transaction do
                if kol.influence_metrics.any?
                  influence_metric = kol.influence_metrics.where(provider: params[:provider]).first
                  influence_metric.update_attributes influence_score: params[:influence_score],
                                                     provider: params[:provider],
                                                     avg_posts: params[:avg_posts],
                                                     avg_comments: params[:avg_comments],
                                                     avg_likes: params[:avg_likes]
                  influence_metric.touch
                  influence_metric.create_or_update_industries params[:industries]
                else
                  influence_metric = kol.influence_metrics.create! calculated: true,
                                                                   influence_score: params[:influence_score],
                                                                   provider: params[:provider],
                                                                   avg_posts: params[:avg_posts],
                                                                   avg_comments: params[:avg_comments],
                                                                   avg_likes: params[:avg_likes]
                  influence_metric.create_or_update_industries params[:industries]
                end
              end
              status 201
              present :error, 0
            rescue Exception => e
              status 400
              present :error, 1
              present :error_message, "#{e.class} : #{e.message.to_s}"
              return
            end
          else
            # create influence score for weibo user that isn't our KOL
            kol_params = {avatar_url: params[:weibo_avatar_url], name: params[:name]}
            kol = Kol.reg_or_sign_in(kol_params)
            influence_metric = kol.influence_metrics.create! calculated: true,
                                                             influence_score: params[:influence_score],
                                                             provider: params[:provider],
                                                             avg_posts: params[:avg_posts],
                                                             avg_comments: params[:avg_comments],
                                                             avg_likes: params[:avg_likes]
            influence_metric.create_or_update_industries params[:industries]
          end
        end
      end
    end
  end
end
