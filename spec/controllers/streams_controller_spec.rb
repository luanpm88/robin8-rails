require 'rails_helper'

describe StreamsController do
  let!(:user) { stub_model(User, :email => 'test@test.com', id: 1) }
  let!(:params) { {} }

  describe "GET" do
    subject { get :index }

    before do
      allow(user).to receive(:can_create_stream).and_return(true)
      allow(controller).to receive(:current_user).and_return user
    end
    let!(:stream) { create :stream, sort_column: 'shares_count', user: user, id: 1 , name: 'Untitled Stream'}

    it "index should be success" do
      subject
      assigns(:streams).should include(stream)
    end

    it { should be_success }
  end

  describe "POST" do
    subject { post :create, params }

    before do
      allow(user).to receive(:can_create_stream).and_return(true)
      allow(controller).to receive(:current_user).and_return user
    end

    it 'should create the stream' do
      params.merge!({ stream: {sort_column: 'shares_count', name: 'Untitled Stream'} })
      subject
      expect(Stream.all.first).not_to be_nil
    end

    it 'should not create the stream(bad sort_column)' do
      params.merge!({ stream: {sort_column: ' ', name: 'Untitled Stream'} })
      subject
      expect(Stream.all.first).to be_nil
    end

    it 'should not create the stream(user cant create stream)' do
      allow(user).to receive(:can_create_stream).and_return(false)
      params.merge!({ stream: {sort_column: 'shares_count', name: 'Untitled Stream'} })
      subject
      expect(Stream.all.first).to be_nil
    end
  end

  describe "PUT" do    
    subject { put :update, ({id: 1}).merge(params) }

    before do
      allow(user).to receive(:can_create_stream).and_return(true)
      allow(controller).to receive(:current_user).and_return user
    end

    let!(:stream) { create :stream, sort_column: 'shares_count', user: user, id: 1 , name: 'Untitled Stream'}

    it "should update the stream's sort_column" do
      params.merge!({ stream: {sort_column: 'published_at'} })
      expect { subject }.to change { stream.reload.sort_column }.from("shares_count").to "published_at"
    end

    it "should update the stream's name" do
      params.merge!({ stream: {name: 'Stream1'} })
      expect { subject }.to change { stream.reload.name }.from('Untitled Stream').to "Stream1"
    end

    it "shouldn't update the stream's sort_column" do
      params.merge!({ stream: {sort_column: nil} })
      expect { subject }.not_to change { stream.reload.sort_column }
    end
  end

  describe "DELETE" do    
    subject { delete :destroy, id: 1 }

    before do
      allow(user).to receive(:can_create_stream).and_return(true)
    end

    context "when stream belongs to current user" do
      it "should destroy stream" do
        stream = FactoryGirl.build(:stream, sort_column: 'shares_count')
        stream.user = user
        subject
        expect(Stream.exists? stream.id).to eq false
      end
    end

    context "when stream belongs to current user" do
      it "shouldn't destroy stream" do
        stream = FactoryGirl.build(:stream, sort_column: 'shares_count', id: 2)
        stream.user = user
        expect { subject }.not_to change(Stream, :count)
      end
    end
  end
end
