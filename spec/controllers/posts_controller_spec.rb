require 'rails_helper'

describe PostsController do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }
  let!(:params) { {} }

  before do
    allow_any_instance_of(Post).to receive(:perform_worker)
    allow(controller).to receive(:current_user).and_return user
  end

  describe "#index" do
    subject { get :index }

    let!(:post) { create :post, user: user, id: 1 }

    it 'index should be success' do
      subject
      expect(assigns(:posts)).to include(post)
    end

    it { is_expected.to be_success }
  end

  describe "#tomorrows" do
    subject { get :tomorrows }

    let!(:post) { create :post, user: user, id: 1 }

    it 'tomorrows should be success' do
      subject
      expect(assigns(:posts)).to include(post)
    end

    it { is_expected.to be_success }
  end

  describe "#others" do
    subject { get :others }

    let!(:post) { create :post, user: user, id: 1 }

    it 'others should be success' do
      subject
      expect(assigns(:posts)).to include(post)
    end

    it { is_expected.to be_success }
  end

  describe "#create" do
    subject { post :create, params }

    it "should create the post" do
      params.merge!({post: {text: 'Test text', scheduled_date: DateTime.now}})
      subject
      expect(Post.all.first).not_to be_nil
    end

    it "shouldn't create the post (without text)" do
      params.merge!({post: {text: '', scheduled_date: DateTime.now}})
      subject
      expect(Post.all.first).to be_nil
    end

    it "shouldn't create the post (without scheduled_date)" do
      params.merge!({post: {text: 'Test title', scheduled_date: ''}})
      subject
      expect(Post.all.first).to be_nil
    end
  end

  describe "#destroy" do
    subject { delete :destroy, id: 1 }

    it "should destroy post" do
      post = create :post, text: "Test text", user: user, id: 1, scheduled_date: DateTime.now
      subject
      expect(Post.exists? post.id).to eq false
    end
  end

  describe "#update" do
    subject { put :update, ({id: 1}).merge(params) }

    let!(:post) { create :post, user: user, id: 1, text: "Test text", scheduled_date: DateTime.now }

    it "should update post" do
      params.merge!({ post: { text: "Test text updated" } })
      expect { subject }.to change { post.reload.text }.from("Test text").to "Test text updated"
    end

    it "shouldn't update post" do
      params.merge!({ post: { text: "" } })
      expect { subject }.not_to change { post.reload.text }
    end

    it "should update post" do
      params.merge!({ post: { scheduled_date: "" } })
      expect { subject }.not_to change { post.reload.text }
    end
  end

  describe "#update_social" do
    subject { put :update, ({id: 1}).merge(params) }

    let!(:post) { create :post, user: user, id: 1, text: "Test text", scheduled_date: DateTime.now }

    it "should update social " do
      params.merge!({ post: { id: 1, text: "Test text changed" }})
      expect { subject }.to change { post.reload.text }.from("Test text").to ("Test text changed")
    end
  end


  describe "#show" do
    subject { get :views, ({id: 1}).merge(params) }

    let!(:post) { create :post, user: user, id: 1 }

    it 'show should be success' do
      subject
      expect(assigns(:post)).to eq(post)
    end

    it { is_expected.to be_success }

  end

end
