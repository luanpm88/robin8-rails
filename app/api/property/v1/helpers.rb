module Property
  module V1
    module Helpers
      extend ActiveSupport::Concern
      included do

        helpers Doorkeeper::Grape::Helpers

        helpers do
          def current_token
            doorkeeper_token
          end

          def current_kol
            return @current_kol if @current_kol
            @current_kol = Kol.where(id: current_token.resource_owner_id).take
          end

          # should never use it !
          def current_user
            return @current_user if @current_user
            @current_user = current_kol.user
          end

          def current_scopes
            current_token.scopes
          end
        end
      end
    end
  end
end
