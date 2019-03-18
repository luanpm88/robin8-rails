module Brand
  module V2
    class BaseInfosAPI < Base
      group do
        before do
          authenticate!
        end

        resource :base_infos do

          desc 'base info'
          get '/' do
            present :tags_list,          Tag.all.order(position: :asc), with: Entities::Tag
            present :trademarks_list,    current_user.trademarks.active, with: Entities::Trademark #我的代理的品牌
            present :competitors,        current_user.competitors, with: Entities::Competitor #竞争品牌
            present :terraces_list,      Terrace.now_use, with: Entities::Terrace # 支持平台
          end

          get 'r8_kols' do
            present :weibo_kols_count,  WeiboAccount.valid.count
            present :wechat_kols_count, PublicWechatAccount.valid.count
          end
          
        end
      end
    end
  end
end