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

          desc "brand search keyword info"
          params do
            requires :keywords, type: String
          end
          post 'search_keyword' do
            keywords = params[:keywords].split(',' || '，')
            keywords.each do |keyword|
              if $redis.exists(keyword)
                $redis.incr("es_search_#{keyword}")
              else
                $redis.set("es_search_#{keyword}",1)
                current_user.search_keywords << keyword
              end
            end

            present error: 0, alert: I18n.t('brand_api.success.messages.save_succeed')
          end
          
        end
      end
    end
  end
end