module API
  module V1_6
    class BigVApplies < Grape::API
      before do
        authenticate!
      end

      resources :big_v_applies do
        desc '提交基本资料'
        params do
          optional :name, type: String
          optional :app_city, type: String
          optional :job_info, type: String
          optional :tag_names, type: String
          optional :desc, type: String
          optional :age, type: String
          optional :gender, type: Integer, values: [0, 1, 2]
        end
        post 'update_profile' do
          current_kol.update_columns(:name => params[:name], :app_city => params[:app_city], :job_info => params[:job_info],
                                     :desc => params[:desc], :gender => params[:gender], :age => params[:age])
          current_kol.tags  = Tag.where(:name => params[:tag_names].split(",")) rescue nil
          current_kol.avatar = params[:avatar]  if params[:avatar].present?
          # current_kol.cover_images = [Image.create!(:referable => current_kol, :avatar => params[:avatar], :sub_type => 'cover')]
          current_kol.save
          current_kol.update_columns(:role_apply_status => 'applying', :role_apply_time => Time.now)   if current_kol.is_big_v?
          present :error, 0
        end

        desc '提交社交账号资料'
        params do
          requires :provider_name, type: String
          optional :homepage, type: String
          requires :price, type: String
          optional :username, type: String
          optional :uid, type: String
          optional :repost_price, type: String
          optional :second_price, type: String
          optional :followers_count, type: String
        end
        post 'update_social' do
          return error_403!({error: 1, detail: 'provider_name 无效' })  unless SocialAccount::Providers.values.include? params[:provider_name]
          provider = SocialAccount::Providers.invert[params[:provider_name]]
          social_account = SocialAccount.find_or_initialize_by(:kol_id => current_kol.id, :provider => provider)
          social_account.homepage = params[:homepage]
          social_account.price = params[:price]
          social_account.username = params[:username]
          social_account.repost_price = params[:repost_price]
          social_account.second_price = params[:second_price]
          social_account.followers_count = params[:followers_count]   if params[:followers_count].present?
          social_account.screenshot = params[:screenshot]             if params[:screenshot].present?
          social_account.save
          current_kol.update_columns(:role_apply_status => 'applying', :role_apply_time => Time.now)   if current_kol.is_big_v?
          present :error, 0
        end

        desc '提交申请'
        params do
          optional :kol_shows, type: String
        end
        post 'submit_apply' do
          params[:kol_shows].split(",").each do |link|
            current_kol.kol_shows.create!(:link => link)
          end if params[:kol_shows].present?
          current_kol.update_columns(:role_apply_status => 'applying', :role_apply_time => Time.now)
          present :error, 0
        end
      end
    end
  end
end