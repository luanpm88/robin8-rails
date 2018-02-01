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
          optional :gender, type: String
        end
        post 'update_profile' do
          if params[:gender] == 'Female'
            gender = 2
          elsif params[:gender] == 'Male'
            gender = 1
          else
            gender = params[:gender].to_i
          end
          app_city = City.where("name like ?", "#{params[:city_name]}%").first.name_en   rescue nil
          current_kol.update_columns(:app_city => app_city, :job_info => params[:job_info],
                                     :desc => params[:desc], :gender => gender, :age => params[:age])
          current_kol.update_columns(name: params[:name]) unless params[:name].include?("****")
          current_kol.tags  = Tag.where(:name => params[:tag_names].split(",")) rescue nil
          current_kol.avatar = params[:avatar]  if params[:avatar].present?
          return error_403!({error: 1, detail: '请先绑定手机号'}) unless current_kol.mobile_number
          # current_kol.cover_images = [Image.create!(:referable => current_kol, :avatar => params[:avatar], :sub_type => 'cover')]
          #current_kol.update_columns(:role_apply_status => 'applying', :role_apply_time => Time.now)   if current_kol.is_big_v?
          current_kol.save
          present :error, 0
        end

        params do
          requires :provider_name, type: String
          optional :homepage, type: String
          optional :price, type: String
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
          social_account.homepage = params[:homepage]  if params[:homepage].present?
          if provider == 'weibo' && social_account.homepage.blank?
            uid = current_kol.identities.where(:name => params[:username]).first.uid  rescue nil
            social_account.homepage = "http://m.weibo.cn/u/#{uid}"       if   uid.present?
          end
          social_account.price = params[:price]           if params[:price].present?
          social_account.username = params[:username]     if params[:username].present?
          social_account.uid = params[:uid]               if params[:uid].present?
          social_account.repost_price = params[:repost_price]
          social_account.second_price = params[:second_price]
          social_account.followers_count = params[:followers_count]   if params[:followers_count].present?
          social_account.screenshot = params[:screenshot]             if params[:screenshot].present?
          social_account.save
          current_kol.update_attribute(:name , params[:username]) if current_kol.name.include?("****")
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
        post 'update_social_v2' do
          return error_403!({error: 1, detail: 'provider_name 无效' })  unless SocialAccount::Providers.values.include? params[:provider_name]
          provider = SocialAccount::Providers.invert[params[:provider_name]]
          bind_record = BindRecord.find_by(:kol_id => current_kol.id , :provider => provider)
          bind_count = bind_record.bind_count
          if bind_record.blank? #活动界面覆盖判断
            bind_record = BindRecord.find_by(:kol_id => current_kol.id , :provider => provider , :bind_count => 2)
            social_account = SocialAccount.new(:kol_id => current_kol.id, :provider => provider)
            social_account.homepage = params[:homepage]  if params[:homepage].present?
            if provider == 'weibo' && social_account.homepage.blank?
              uid = current_kol.identities.where(:name => params[:username]).first.uid  rescue nil
              social_account.homepage = "http://m.weibo.cn/u/#{uid}"       if   uid.present?
            end
            social_account.price = params[:price]           if params[:price].present?
            social_account.username = params[:username]     if params[:username].present?
            social_account.uid = params[:uid]               if params[:uid].present?
            social_account.repost_price = params[:repost_price]
            social_account.second_price = params[:second_price]
            social_account.followers_count = params[:followers_count]   if params[:followers_count].present?
            social_account.screenshot = params[:screenshot]             if params[:screenshot].present?
            social_account.save
            #current_kol.update_columns(:role_apply_status => 'applying', :role_apply_time => Time.now)   if current_kol.is_big_v?
            bind_count = bind_record.bind_count - 1
            bind_record.update(:bind_count => bind_count)
            present :error, 0
          elsif bind_count > 0 # 测试:解除次数限制
            social_account = SocialAccount.find_by(:kol_id => current_kol.id, :provider => provider)
            if social_account.blank?
              social_account = SocialAccount.new(:kol_id => current_kol.id, :provider => provider)
              social_account.homepage = params[:homepage]  if params[:homepage].present?
              if provider == 'weibo' && social_account.homepage.blank?
                uid = current_kol.identities.where(:name => params[:username]).first.uid  rescue nil
                social_account.homepage = "http://m.weibo.cn/u/#{uid}"       if   uid.present?
              end
              social_account.price = params[:price]           if params[:price].present?
              social_account.username = params[:username]     if params[:username].present?
              social_account.uid = params[:uid]               if params[:uid].present?
              social_account.repost_price = params[:repost_price]
              social_account.second_price = params[:second_price]
              social_account.followers_count = params[:followers_count]   if params[:followers_count].present?
              social_account.screenshot = params[:screenshot]             if params[:screenshot].present?
              social_account.save
              #current_kol.update_columns(:role_apply_status => 'applying', :role_apply_time => Time.now)   if current_kol.is_big_v?
              bind_count = bind_count - 1
              bind_record.update(:bind_count => bind_count)
              present :error, 0
            elsif bind_record.unbind_count.blank? || bind_record.unbind_count == true
              social_account = SocialAccount.new(:kol_id => current_kol.id, :provider => provider)
              social_account.homepage = params[:homepage]  if params[:homepage].present?
              if provider == 'weibo' && social_account.homepage.blank?
                uid = current_kol.identities.where(:name => params[:username]).first.uid  rescue nil
                social_account.homepage = "http://m.weibo.cn/u/#{uid}"       if   uid.present?
              end
              social_account.price = params[:price]           if params[:price].present?
              social_account.username = params[:username]     if params[:username].present?
              social_account.uid = params[:uid]               if params[:uid].present?
              social_account.repost_price = params[:repost_price]
              social_account.second_price = params[:second_price]
              social_account.followers_count = params[:followers_count]   if params[:followers_count].present?
              social_account.screenshot = params[:screenshot]             if params[:screenshot].present?
              social_account.save
              #current_kol.update_columns(:role_apply_status => 'applying', :role_apply_time => Time.now)   if current_kol.is_big_v?
              bind_count = bind_count - 1
              bind_record.update(:bind_count => bind_count , :unbind_count => false)
              present :error, 0
            else
              return error_403!({error: 1, detail: '因解绑次数不足,本月无法再次绑定'})
            end
          else
            return error_403!({error: 1, detail: '因解绑次数不足,本月无法再次绑定'})
          end
        end

        desc '提交申请'
        params do
          optional :kol_shows, type: String

        end
        post 'submit_apply' do
          params[:kol_shows].split(",").each do |link|
            current_kol.kol_shows.find_or_create_by(:link => link)
          end if params[:kol_shows].present?

          current_kol.update_columns(:role_apply_status => 'passed', :kol_role => 'big_v', :role_apply_time => Time.now)

          # if current_kol.kol_keywords.size == 0  && current_kol.tags.size > 0
          #   current_kol.tags.each do |tag|
          #     KolKeyword.create!(:kol_id => current_kol.id, :keyword => tag.label)
          #   end
          # end
          present :error, 0
        end
      end
    end
  end
end
