module Property
  module V1
    class Profile < Base
      include Property::V1::Helpers

      resource :profile do
        before do
          doorkeeper_authorize!
        end

        get "/" do
          present current_kol, with: Property::V1::Entities::Profile
        end
      end
    end
  end
end