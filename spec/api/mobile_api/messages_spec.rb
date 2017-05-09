require 'rails_helper'

RSpec.describe "V1 Messages" do

  let(:kol) { create(:kol)}
  let(:messages) { create_list(:message, 12, receiver_type: 'Kol',
                               receiver_id: kol.id, created_at: DateTime.now + 1.minute) }

  before :each do
    Grape::Endpoint.before_each do |endpoint|
      allow(endpoint).to receive(:current_kol).and_return(kol)
    end
    kol.messages << messages
  end

  describe "GET Messages" do
    it "returns messages list" do
      get '/api/v1/messages', {status: 'all', with_message_stat: 'y'}

      expect(JSON.parse(response.body)['messages'].size).to eq 10 #10 because of pagination
      expect(response.status).to eq 200
    end

    describe "with incorrect status" do
      it "returns grape exception error message" do
        get '/api/v1/messages', {status: 'bla', with_message_stat: 'y'}

        expect(JSON.parse(response.body)['message']).to eq 'status does not have a valid value'
        expect(response.status).to eq 400
      end
    end
  end


end
