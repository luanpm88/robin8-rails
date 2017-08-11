require 'rails_helper'

RSpec.describe "V2_0 Influence metric" do

  let!(:kol) { create(:kol)}
  let!(:identity) { create(:identity, kol_id: kol.id, provider: 'weibo', uid: 'weibo_boss')}

  before do
    allow_any_instance_of(@current_kol).to_return(:kol)
  end

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

  describe 'kol with calculated influence score' do
    it 'returns valid json' do
      # first create influence score from hash
      post '/prop/v1/influence_metric/save_influence', valid_hash

      get '/api/v2_0/kols/influence_score'
      puts JSON.parse(response.body)
      expect(JSON.parse(response.body)['error']).to eq 0
      expect(JSON.parse(response.body)['calculated']).to eq true
      expect(response.status).to eq 200
    end
  end

end
