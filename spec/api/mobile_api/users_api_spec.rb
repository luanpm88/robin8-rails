require 'rails_helper'

RSpec.describe "V1 Users" do

  let!(:kol) { create(:kol, mobile_number: '123456',
                           app_platform: 'old_platform', app_version: 1,
                           device_token: 123)}
  before do
    allow(YunPian::SendRegisterSms).to receive(:verify_code).and_return(true)
    allow_any_instance_of(Kol).to receive(:get_rongcloud_token).and_return(nil)
    allow_any_instance_of(Kol).to receive(:update_attributes).and_raise(ActiveRecord::StaleObjectError.new('erorr', 'msg'))
  end

  describe "POST sign_in for existing user when it fails to update atributes" do
    it "raises exception" do
      post '/api/v1/kols/sign_in', {mobile_number: '123456', code: '123',
                                    app_platform: 'new_platform', app_version: 1,
                                    device_token: 123}

      expect(response.code).to eq '201'
    end
  end
end
