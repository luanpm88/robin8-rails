module API
  module V1_6
    class KolApplies < Grape::API
      before do
        authenticate!
      end

      resources :kol_applies do
        desc '提交基本资料'
        params do
          requires :avatar, type: Hash
          requires :name, type: String
          optional :app_city, type: String
          optional :job_info, type: String
          optional :profession_ids, type: String
          optional :brief, type: String
        end
        post 'update_profile' do
          current_kol.update_columns(:name => params[:name], :app_city => params[:app_city], :job_info => params[:job_info],
                                     :brief => params[:brief])
          current_kol.professions  = Profession.where(:id => params[:profession_ids].split(",")) rescue nil
          current_kol.cover_images = [Image.create!(:referable => current_kol, :avatar => params[:avatar], :sub_type => 'cover')]
          current_kol.save
          present :error, 0
        end

        desc '提交社交账号资料'
        params do
          requires :provider, type: String
          requires :homepage, type: String
          requires :price, type: String
          optional :repost_price, type: String
          optional :second_price, type: String
          optional :followers_count, type: String
          optional :screenshot, type: Hash
        end
        post 'update_social' do
          social_account = SocialAccount.find_or_initialize_by(:kol_id => current_kol.id, :provider => params[:provider])
          social_account.homepage = params[:homepage]
          social_account.price = params[:price]
          social_account.repost_price = params[:repost_price]
          social_account.second_price = params[:second_price]
          social_account.followers_count = params[:followers_count]   if params[:followers_count].present?
          social_account.screenshot = params[:screenshot]             if params[:screenshot].present?
          social_account.save
          present :error, 0
        end

        desc '提交申请'
        params do
          optional :kol_shows, type: String
        end
        post 'submit_apply' do
          if params[:kol_shows].present?
            JSON.parse(params[:kol_shows]).each do |link|
              current_kol.kol_shows.create!(:link => link)
            end
          end
          current_kol.role_apply_status == 'pending' if current_kol
          present :error, 0
        end
      end
    end
  end
end
