require 'rails_helper'

describe Users::RegistrationsController, :type => :controller do
  let!(:params) { {} }

  describe 'Profile Update' do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user] 
      allow(controller).to receive(:current_user).and_return nil
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
      sign_in @user
      allow(controller).to receive(:current_user).and_return @user
    end

    context "update" do
      it "should update user email with an empty password" do
        params.merge!({ user: {id: 1, email: 'test2@test.com', password: '', password_confirmation: ''}})
        expect{
          put :update, params
        }.to change {@user.reload.email}.from('test@test.com').to('test2@test.com')
      end

      it "should update user email and pasword with a correct password" do
        params.merge!({ user:{
                          id: 1,
                          email: 'test2@test.com',
                          current_password: 'password',
                          password: 'password1',
                          password_confirmation: 'password1'}
                      })
        expect{
          put :update, params
        }.to change {@user.reload.email}.from('test@test.com').to('test2@test.com')
      end

      it "shouldn't update user email and password with an empty password" do
        params.merge!({ user:{
                          id: 1,
                          email: 'test2@test.com',
                          current_password: '',
                          password: 'password1',
                          password_confirmation: 'password1'}
                      })
        expect{
          put :update, params
        }.not_to change {@user.reload.email}
      end

      it "shouldn't update user with an empty email" do
        params.merge!({ user:{
                          id: 1,
                          email: '',
                          password: '',
                          password_confirmation: ''}
                      })
        expect{
          put :update, params
        }.not_to change {@user.reload.email}
      end

    end
  end
end