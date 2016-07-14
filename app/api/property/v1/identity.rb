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
          return present :message, "第三方帐号解除绑定成功" if @identity
          error!({error: '解绑的第三方账号不存在'}, 400)
        end
      end
    end
  end
end
