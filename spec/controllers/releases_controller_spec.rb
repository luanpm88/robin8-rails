require 'rails_helper'

describe ReleasesController do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }
  let!(:params) { {} }

  before do
    allow(user).to receive(:can_create_release).and_return(true)
    allow(user).to receive(:can_create_newsroom).and_return(true)
    allow(controller).to receive(:current_user).and_return user
    allow_any_instance_of(NewsRoom).to receive(:create_campaign)
    allow_any_instance_of(Release).to receive(:update_images_links)
    @request.host = "test.example.com"
  end

  describe "#index" do
    subject { get :index }

    let!(:news_room) { create :news_room, user: user, id: 1 }
    let!(:release) { create :release, user: user, title: 'Test release', news_room_id: 1 }

    it 'index should be success' do
      subject
      expect(assigns(:releases)).to include(release)
    end

    it { is_expected.to be_success }
  end

  describe "#create" do
    subject { post :create, params }

    it "should create the release" do
      params.merge!({release: {title: 'Test title'}})
      subject
      expect(Release.all.first).not_to be_nil
    end

    it "shouldn't create the release (without title)" do
      params.merge!({release: {title: ''}})
      subject
      expect(Release.all.first).to be_nil
    end

    it "shouldn't create the release (user can't create release)" do
      allow(user).to receive(:can_create_release).and_return(false)
      params.merge!({release: {title: 'Test title'}})
      subject
      expect(Release.all.first).to be_nil
    end
  end

  describe "#show" do
    subject { get :views, ({id: 1}).merge(params) }

    let!(:news_room) { create :news_room, user: user, id: 1, subdomain_name: 'test' }
    let!(:release) { create :release, user: user, title: 'Test release!!!', news_room_id: 1, id: 1 }

    it 'should be success without preview' do
      subject
      expect(assigns(:release)).to eq(release)
    end

    it 'should be success with preview' do
      @request.host = "test-preview.example.com"
      subject
      expect(assigns(:release)).to eq(release)
    end

    it { is_expected.to be_success }
  end

  describe "#extract_from_word" do
    subject { post :extract_from_word, ({file: fixture_file_upload('files/test.docx', 'application/msword')}).merge(params) }
    it "should render html from doc file" do
      subject
      is_expected.to be_success
    end
  end

  describe "#update" do
    subject { put :update, ({id: 1}).merge(params) }

    let!(:news_room) { create :news_room, user: user, id: 1 }
    let!(:release) { create :release, user: user, id: 1, title: 'Test release', news_room_id: 1 }

    it "should update the release title" do
      params.merge!({ release: {title: 'Test release updated'} })
      expect { subject }.to change { release.reload.title }.from('Test release').to 'Test release updated'
    end

    it "shouldn't update the release title when empty" do
      params.merge!({ release: {title: ''} })
      expect { subject }.not_to change { release.reload.title }
    end
  end

  describe "#destroy" do
    subject { delete :destroy, id: 1 }

    it "should destroy release" do
      release = create :release, title: 'Test title', user: user, news_room_id: 1, id: 1
      subject
      expect(Release.exists? release.id).to eq false
    end
  end
end
