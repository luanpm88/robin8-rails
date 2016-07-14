module Property
  module V1
    class Identity < Base
      include Property::V1::Helpers

      resource :identity do
        before do
          doorkeeper_authorize!
        end

        params do
          requires :id, type: Integer
        end
        delete "/unbind" do
          @identity = current_kol.identities.find_by(declared(params)[:id]).try(:delete)
          return present :error, 0 if @identity
          error!({error: '删除的账号不存在'}, 400)
        end
      end
    end
  end
end
