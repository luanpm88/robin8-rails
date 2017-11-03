require 'rails_helper'

RSpec.describe "influence_metric api" do

  let!(:kol) { create(:kol)}
  let!(:identity) { create(:identity, kol_id: kol.id, provider: 'weibo', uid: 'weibo_boss')}

  let(:valid_hash) {
    {
      api_token: 'only-heroes-can-create-influence',
      provider: 'weibo',
      provider_uid: 'weibo_boss',
      influence_score: '88',
      avg_posts: '1234',
      avg_comments: '2342',
      avg_likes: '232',
      industries: [
        {
          industry_name: 'industry1',
          industry_score: '2342',
          avg_posts: '134',
          avg_comments: '134',
          avg_likes: '23423',
        },
        {
          industry_name: 'industry2',
          industry_score: '1232',
          avg_posts: '13',
          avg_comments: '4',
          avg_likes: '23',
        }
      ]
    }
  }

  let(:valid_update_hash) {
    {
      api_token: 'only-heroes-can-create-influence',
      provider: 'weibo',
      provider_uid: 'weibo_boss',
      influence_score: '666',
      avg_posts: '1234',
      avg_comments: '2342',
      avg_likes: '232',
      industries: [
        {
          industry_name: 'industry1',
          industry_score: '6661',
          avg_posts: '134',
          avg_comments: '134',
          avg_likes: '23423',
        }
      ]
    }
  }

  let(:invalid_hash) {
    {
      api_token: 'only-heroes-can-create-influence',
      provider: 'weibo',
      provider_uid: 'weibo_boss',
      influence_score: '88',
      avg_posts: '1234',
      avg_comments: '2342',
      avg_likes: 123,
      industries: 'here should be array',
    }
  }


  describe 'valid JSON' do
    it 'creates user influence data' do
      post "/prop/v1/influence_metric/save_influence", valid_hash

      im = kol.influence_metrics
      expect(im.size).to eq 1
      expect(im.first.influence_level).to eq '影响力较差'
      expect(im.first.influence_industries.size).to eq 2
      expect(JSON.parse(response.body)["error"]).to eq 0
      expect(response.status).to eq 201
    end

    it 'updates user influence if it existed before' do
      # first let's create influence
      post "/prop/v1/influence_metric/save_influence", valid_hash

      # and update with different data
      post "/prop/v1/influence_metric/save_influence", valid_update_hash
      im = kol.influence_metrics
      expect(im.size).to eq 1
      expect(im.first.influence_score).to eq 666 # updated industry score
      expect(im.first.influence_industries.size).to eq 1 # removed second industry
      expect(im.first.influence_industries.first.industry_score).to eq 6661 # updated value in 1st industry
      expect(JSON.parse(response.body)["error"]).to eq 0
      expect(response.status).to eq 201
    end

  end

  describe 'invalid JSON' do
    it 'returns error' do
      post "/prop/v1/influence_metric/save_influence", invalid_hash
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)["error_message"]).to eq "NoMethodError : undefined method `each' for \"here should be array\":String"
    end
  end

  describe 'saving influence score for KOLs that does not exist in MySQL DB' do
    it 'saves influence score data' do
      # TODO: when identity gets created, it has to be linked with existing influence score
    end
  end
end
