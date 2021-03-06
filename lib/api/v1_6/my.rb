module API
  module V1_6
    class My < Grape::API
      resources :my do
        before do
          authenticate!
        end

        get 'show' do
          present :error, 0
          present :hide, 1
          present :detail, $redis.get('ios_detail') || 20
          present :kol, current_kol, with: API::V1_6::Entities::BigVEntities::My
          present :is_open_indiana, true
          present :has_any_unread_message, current_kol.unread_messages.any?
          present :brand_campany_name, current_kol.user.try(:campany_name)
          present :is_show_invite_code, $redis.get('invite_switch')
          present :logo, current_kol.strategy[:logo]
          present :vest_bag_detail, $redis.get('vest_bag_detail')
          present :put_switch, $redis.get('put_switch') # 1:显示， 0:隐藏
          present :put_count, $redis.get('put_count')
          present :completed_rate, current_kol.completed_rate
          present :creator_is_read, current_kol.creator.try(:is_read).try(:value)
          present :public_wechat_account_is_read, current_kol.public_wechat_account.try(:is_read).try(:value)
          present :weibo_account_is_read, current_kol.weibo_account.try(:is_read).try(:value)
          present :read_list, current_kol.set_account_have_read
          present :vote_infos, [current_kol.vote_infos]
        end

        params do
          optional :page, type: Integer
        end
        get 'friends' do
          friends = current_kol.friends.page(params[:page]).per_page(10)
          to_paginate(friends)
          present :error, 0
          present :big_vs, friends, with: API::V1_6::Entities::BigVEntities::Summary
        end
      end
    end
  end
end
