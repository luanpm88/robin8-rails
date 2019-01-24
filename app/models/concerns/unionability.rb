module Concerns
  module Unionability
    extend ActiveSupport::Concern

    def union_access_token
      return @union_access_token if @union_access_token

      @union_access_token = Doorkeeper::AccessToken.find_or_create_for(
        Doorkeeper::Application.where(union: true).take,
        self.id,
        Doorkeeper.configuration.scopes,
        Doorkeeper.configuration.access_token_expires_in,
        Doorkeeper.configuration.refresh_token_enabled?)
    end

    module ClassMethods
      def authenticate_password(conditions)
        user = where([
          "mobile_number = :value OR lower(email) = :value",
          { :value => conditions[:login].downcase }
        ]).take

        return unless user
        user.valid_password?(conditions["password"]) ? user : nil
      end

      def authenticate_login(conditions)
        user = where([
          "mobile_number = :value OR lower(email) = :value",
          { :value => conditions.downcase }
        ]).take
      end
    end
  end
end
