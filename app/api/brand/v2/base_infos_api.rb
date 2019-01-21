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
            present :tags_list,         Tag.all.order(position: :asc), with: Entities::Tag
            present :trademarks_list,   current_user.trademarks, with: Entities::Trademark
          end


        end
      end
    end
  end
end