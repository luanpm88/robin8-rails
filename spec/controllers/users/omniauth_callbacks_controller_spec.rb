require 'rails_helper'

describe Users::OmniauthCallbacksController do
  describe 'Social accounts sign up' do
     before do
      request.env["devise.mapping"] = Devise.mappings[:user] 
      allow(controller).to receive(:current_user).and_return nil

      allow_any_instance_of(User).to receive(:create_default_news_room) do
        true
      end
    end

    context "facebook" do
      before do
        request.env["omniauth.auth"] = facebook_hash
      end

      it "creates a user from a facebook auth hash" do
        expect{
          post :facebook
        }.to change {User.count}.by(1)
      end

      it "returns an already existing user" do
        post :facebook
        expect{
          post :facebook
        }.to_not change {User.count}
      end
    end

    context "google" do
      before do
        request.env["omniauth.auth"] = google_hash
      end

      it "creates a user from a google auth hash" do
        expect{
          post :google_oauth2
        }.to change {User.count}.by(1)
      end

      it "returns an already existing user" do
        post :google_oauth2
        expect{
          post :google_oauth2
        }.to_not change {User.count}
      end
    end
  end

  describe 'Social accounts connect' do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]       

      allow_any_instance_of(User).to receive(:create_default_news_room) do
        true
      end
      
      @attr = {
        :name => "Example User",
        :email => "test@test.com",
        :password => "password",
        :password_confirmation => "password"
      }
      @user = User.create!(@attr)
      allow(controller).to receive(:current_user).and_return @user
    end

    context "facebook" do
      before do
        request.env["omniauth.auth"] = facebook_hash
      end

      it "should create identity for user" do
        expect{
          post :facebook
        }.to change {@user.identities.count}.by(1)
      end
    end

    context "google_oauth2" do
      before do
        request.env["omniauth.auth"] = google_hash
      end

      it "should create identity for user" do
        expect{
          post :google_oauth2
        }.to change {@user.identities.count}.by(1)
      end
    end

    context "twitter" do
      before do
        request.env["omniauth.auth"] = twitter_hash
      end

      it "should create identity for user" do
        expect{
          post :twitter
        }.to change {@user.identities.count}.by(1)
      end
    end

    context "linkedin" do
      before do
        request.env["omniauth.auth"] = linkedin_hash
      end

      it "should create identity for user" do
        expect{
          post :linkedin
        }.to change {@user.identities.count}.by(1)
      end
    end
  end
end