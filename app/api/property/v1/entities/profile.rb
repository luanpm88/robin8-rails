module Property
  module V1
    module Entities
      class Identity < Entities::Base
        expose :id
        expose :name
        expose :provider
        expose :avatar_url
      end

      class Profile < Entities::Base
        expose :id, :email, :mobile_number, :avatar_url

        expose :name do |obj|
          obj.safe_name
        end

        expose :city do |obj|
          obj.app_city_label
        end

        expose :influence_score
        expose :avail_amount

        expose :weibo, using: Identity do |obj|
          obj.identities.where(provider: "weibo").take
        end

        expose :qq, using: Identity do |obj|
          obj.identities.where(provider: "qq").take
        end

        expose :wechat, using: Identity do |obj|
          obj.identities.where(provider: "wechat").take
        end
        expose :show_count do |obj|
          obj.kol.show_count rescue 30
        end
      end
    end
  end
end
