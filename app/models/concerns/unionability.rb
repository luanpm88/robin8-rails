module Concerns
  module Unionability
    extend ActiveSupport::Concern

    def union_access_token
      return @union_access_token if @union_access_token
      client = Doorkeeper::Application.where(union: true).take
      @union_access_token = Doorkeeper::AccessToken.find_or_create_for(client, self.id, nil, 7200.seconds, false)
    end

    module ClassMethods
      def authenticate_password(conditions)
        user = where([
          "mobile_number = :value OR lower(email) = :value",
          { :value => conditions[:login].downcase }
        ]).take

        user.valid_password?(conditions["password"]) ? user : nil
      end
    end
  end
end
