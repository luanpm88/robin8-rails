module Property
  module V1
    class Account < Base
      include Property::V1::Helpers

      resource :account do
        before do
          doorkeeper_authorize!
        end

        get "/" do
          present current_kol, with: Property::V1::Entities::Account
        end
      end
    end
  end
end