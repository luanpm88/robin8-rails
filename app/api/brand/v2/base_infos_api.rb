module Brand
  module V2
    class BaseInfosAPI < Base
      group do
        before do
          # authenticate!
        end

        resource :base_infos do

          desc 'base info'

          get '/' do
            current_user = User.find 829
            present :tags_list,         Tag.all.order(position: :asc), with: Entities::Tag
            present :trademarks_list,   current_user.trademarks, with: Entities::Trademark
            present :terraces_list,     Terrace.all, with: Entities::Terrace
          end


        end
      end
    end
  end
end