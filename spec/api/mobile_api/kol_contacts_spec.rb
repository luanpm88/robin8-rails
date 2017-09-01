require 'rails_helper'

RSpec.describe "V2_0 Kol contacts" do

  let!(:kol) { create(:kol)}
  let!(:kol1) { create(:kol, mobile_number: '1234')}
  let!(:kol2) { create(:kol, mobile_number: '2345')}


  before do
    Grape::Endpoint.before_each do |endpoint|
      allow(endpoint).to receive(:current_kol).and_return(kol)
    end
    kol.invited_users.clear
    kol.invited_users << '2345'
    kol.invited_users << '3456'
  end

  # user has:
  # - already invited 2345 and 3456
  # - 2345 should be removed from kol's invitation list because in the meantime he became kol
  # - 3456 should be returned as already_invited
  # - 4567 should be returned as not_invited
  describe 'asking for kol mobile contacts status' do
    it 'returns kols statuses' do
      contacts = ['1234', '2345', '3456', '4567'].to_s
      post '/api/v2_0/contacts/kol_contacts', {contacts: contacts}
      res = JSON.parse(response.body)
      kol_users = res['kol_users']
      expect(kol_users[0]['status']).to eq 'already_kol'
      expect(kol_users[1]['status']).to eq 'already_kol'
      expect(kol_users[2]['status']).to eq 'already_invited'
      expect(kol_users[3]['status']).to eq 'not_invited'
    end
  end

  describe 'inviting new user' do
    it 'sends invite' do
      post '/api/v2_0/contacts/send_invitation', {mobile_number: '18616114344'}
      res = JSON.parse(response.body)
      expect(kol.invited_users.members).to include('18616114344')
      expect(res['error']).to eq 0
    end
  end
end
