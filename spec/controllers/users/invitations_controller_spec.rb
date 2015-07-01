require 'rails_helper'

describe Users::InvitationsController, :type => :controller do
  let!(:user) { stub_model(User, :email => 'test@test.com', id: 1) }
  let!(:params) { {} }

  describe 'Invitations' do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      allow_any_instance_of(User).to receive(:create_default_news_room) do
        true
      end

      @user = User.create(:email=>'test@test.com',
                       :password=>'password',
                       :password_confirmation=>'password')
      sign_in @user
      allow_any_instance_of(Users::InvitationsController).to receive(:current_user) do
        @user
      end

      allow(request.env['warden']).to receive(:authenticate!).and_return(@user)
    end

    it "user should be invited" do
      params.merge!({ user: {email: 'test2@test.com', is_primary: 'false'} })
      expect{
        post :create, params
      }.to change {User.count}.by(1)
    end

    it "user shouldn't be invited" do
      expect{
        post :create, params
      }.to_not change {User.count}
    end

  end
end