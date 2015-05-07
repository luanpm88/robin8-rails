require 'spec_helper'
require 'rails_helper'

describe Stream do
  
  let(:user) { stub_model(User, :email => 'test@test.com', id: 1) }

  describe "validations of new stream" do
    before(:each) do
      allow(user).to receive(:can_create_stream).and_return(true)
    end

    it "requires a correct sort_column" do
      [nil, "", " "].each do |sort_column|
        stream = FactoryGirl.build(:stream, sort_column: sort_column, topics: [{"id"=>"Facebook", "text"=>"Facebook"}])
        stream.user = user
        expect(stream).not_to be_valid
      end
    end

    it "requires a correct sort_column(bad value)" do
      ["published_at", "shares_count"].each do |sort_column|
        stream = FactoryGirl.build(:stream, sort_column: sort_column)
        stream.user = user
        expect(stream).to be_valid
      end
    end

    it "requires a correct position" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.user = user
      stream.save

      expect(stream).to be_valid
    end

    it "requires a position 1" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.user = user
      expect(stream.position).to eq 1
    end

    context "setting correct position" do
      let(:stream) { create :stream, sort_column: 'shares_count', user: user, id: 1 , name: 'first'}
      let(:stream2) { create :stream, sort_column: 'shares_count', user: user, id: 2 , name: 'second'}
      it "requires a position 2" do
        expect(stream2.position).to eq 2
      end
    end

    it "requires a correct position(bad value)" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.position = 0
      stream.user = user
      expect(stream).to be_valid
    end

    it "'s user should have available streams count" do
      allow(user).to receive(:can_create_stream).and_return(false)

      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.user = user
      expect(stream).not_to be_valid
    end
  end

  describe "before and after callbacks for user features - " do
    let!(:feature) { FactoryGirl.build(:feature, slug: 'media_monitoring', id: 1, name: 'Streams - Media Monitoring') }
    let!(:user_feature) { FactoryGirl.build(:user_feature, feature_id: 1, user_id: user.id, available_count: 3) }
    # let!(:stream) { FactoryGirl.build(:stream, sort_column: 'published_at', user_id: user.id) }
    
    before(:each) do
      allow(user).to receive(:can_create_stream).and_return(true)
      feature.save!
      user_feature.save
    end

    it "should decrease and decrease available monitoring user features count" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.user = user
      stream.save
      expect(user.user_features.first.available_count).to eq 2
      
      stream.destroy
      expect(user.user_features.first.available_count).to eq 3
    end
  end
end
