require 'rails_helper'

RSpec.describe "V2_0 Influence metric" do

  let!(:kol) { create(:kol)}
  let!(:identity) { create(:identity, kol_id: kol.id, provider: 'weibo', uid: 'weibo_boss')}
  let!(:influence_metrics) { create(:influence_metric,
                                    calculated: true,
                                    provider: 'weibo',
                                    kol_id: kol.id,
                                    influence_score: '88',
                                    avg_posts: '1234',
                                    avg_comments: '2342',
                                    avg_likes: '232')}
  let!(:influence_industry1) { create(:influence_industry,
                                     industry_name: 'industry1',
                                     industry_score: '2342',
                                     avg_posts: '134',
                                     avg_comments: '134',
                                     avg_likes: '23423',
                                     influence_metric_id: influence_metrics.id)}

  let!(:influence_industry2) { create(:influence_industry,
                                     industry_name: 'industry2',
                                     industry_score: '12',
                                     avg_posts: '3',
                                     avg_comments: '2',
                                     avg_likes: '1',
                                     influence_metric_id: influence_metrics.id)}

  before do
    Grape::Endpoint.before_each do |endpoint|
      allow(endpoint).to receive(:current_kol).and_return(kol)
    end
  end

  describe 'kol with calculated influence score' do
    it 'returns valid json' do
      get '/api/v2_0/kols/influence_score'
      expect(response.status).to eq 200

      res = JSON.parse(response.body)
      expect(res['error']).to eq 0
      expect(res['calculated']).to eq true
      expect(res['influence_level']).to eq '影响力优秀'
      expect(res['influence_score_percentile']).to eq '超过0%的用户'
      expect(res['industries'].size).to eq 2
    end
  end

end
