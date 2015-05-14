require 'rails_helper'

describe NewsRoomsController do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }
  let!(:params) { {} }
 
  before do
    allow(user).to receive(:can_create_newsroom).and_return(true)
    allow(controller).to receive(:current_user).and_return user
    allow_any_instance_of(NewsRoom).to receive(:create_campaign)
  end

  describe "#index" do
    subject { get :index }

    let!(:news_room) { create :news_room, user: user }

    it 'index should be success' do
      subject
      expect(assigns(:news_rooms)).to include(news_room)
    end

    it { is_expected.to be_success }
  end

  describe "#create" do
    subject { post :create, params }

    it "should create news room" do
      params.merge!({news_room: {company_name: 'Test company name', subdomain_name: 'test-subdomain'}})
      subject
      expect(NewsRoom.all.first).not_to be_nil
    end

    it "shouldn't create news room (without company_name)" do
      params.merge!({news_room: {company_name: '', subdomain_name: 'test-subdomain'}})
      subject
      expect(NewsRoom.all.first).to be_nil
    end

    it "shouldn't create news room (without subdomain_name)" do
      params.merge!({news_room: {company_name: 'Test company name', subdomain_name: ''}})
      subject
      expect(NewsRoom.all.first).to be_nil
    end

    it "shouldn't create news room (user can't create news room)" do
      allow(user).to receive(:can_create_newsroom).and_return(false)
      params.merge!({news_room: {company_name: 'Test company name', subdomain_name: 'test-subdomain'}})
      subject
      expect(NewsRoom.all.first).to be_nil
    end
  end

  describe "#show" do
    subject { get :show, ({id: 1}).merge(params) }

    let!(:news_room) { create :news_room, user: user, id: 1, subdomain_name: 'test' }
    
    it "should be success" do
      subject
      expect(assigns(:news_room)).to eq(news_room)
    end
  end

  describe "#update" do
    subject { put :update, ({id: 1}).merge(params) }

    let!(:news_room) { create :news_room, user: user, id: 1, company_name: 'Test company' }

    it "should update the news_room company_name" do
      params.merge!({ news_room: {company_name: 'Test company updated'} })
      expect { subject }.to change { news_room.reload.company_name }.from('Test company').to 'Test company updated'
    end

    it "should'n update the news_room company_name when empty" do
      params.merge!({ news_room: {company_name: ''} })
      expect { subject }.not_to change { news_room.reload.company_name }
    end
  end

  describe "#destroy" do
    subject { delete :destroy, id: 2 }
    let!(:news_room) { create :news_room, user: user, id: 1, default_news_room: true }
    let!(:news_room) { create :news_room, user: user, id: 3 }

    it "should destroy news_room" do
      news_room = create :news_room, id: 2, user: user
      subject
      expect(NewsRoom.find(2)).to eq nil
    end
  end
end
