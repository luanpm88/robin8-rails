require 'rails_helper'


describe ReleasesController do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1, is_primary: 1) }
  let!(:params) { {} }

  describe "GET" do
    subject { get :index }
    
    before do
      allow(user).to receive(:can_create_release).and_return(true)
      allow(user).to receive(:can_create_newsroom).and_return(true)
      allow(controller).to receive(:current_user).and_return user
      NewsRoom.any_instance.stub(:create_campaign)
    end

    let!(:news_room) { create :news_room, user: user, subdomain_name: 'test', id: 1 }
    let!(:release) { create :release, user: user, title: 'Test release', text: 'Release text', news_room_id: 1, slug: 'test-release' }

    it 'index should be success' do
      subject
      assigns(:releases).should include(release)
    end

    it { should be_success }
  end

end
