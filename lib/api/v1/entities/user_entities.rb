module API
  module V1
    module Entities
      class UserSummary < Grape::Entity
        expose :name, :phone, :invite_code
        expose :avatar do |user|
          user.avatar.url(:thumb)
        end
      end

      class UserAccount < Grape::Entity
        expose :account_amount, :available_amount, :account_frozen_amout, :account_bail
      end

      class UserMore < Grape::Entity
        expose :private_token
        expose :role
        expose :verify
        expose :id
        expose :auth_profile_state do |user|
          user.auth_profile.aasm_state rescue ''
        end
        expose :can_invate do |user|
          user.can_invite?
        end
        expose :account, :using => API::V1::Entities::UserAccount
        expose :point
      end

    end
  end
end
