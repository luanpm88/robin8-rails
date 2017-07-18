require 'rails_helper'

RSpec.describe "V1_6 Big_V" do

  let!(:kol) { create(:kol, mobile_number: '123456',
                      app_platform: 'old_platform', app_version: 1,
                      device_token: 123)}
  let!(:social_account) { create(:social_account, provider: 'wechat', kol_id: kol.id) }

  describe 'v1_6 unbind_social_account' do

    it 'unbinds social account' do
      post '/api/v1_6/big_v/unbind_social_account', {kol_id: kol.id,
                                                     provider: 'wechat',
                                                     id: social_account.id}
      expect(JSON.parse(response.body)['error']).to eq 0
    end

    it 'returns error when account and kol not found' do
      post '/api/v1_6/big_v/unbind_social_account', {kol_id: 666,
                                                     provider: 'wechat',
                                                     id: 666}
      expect(JSON.parse(response.body)['error']).to eq 1
    end

  end

end
