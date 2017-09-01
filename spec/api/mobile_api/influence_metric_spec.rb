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
                                    avg_likes: '232.234234')}
  let!(:influence_industry1) { create(:influence_industry,
                                     industry_name: 'industry1',
                                     industry_score: '2342',
                                     avg_posts: '134',
                                     avg_comments: '134',
                                     avg_likes: '23423.243234',
                                     influence_metric_id: influence_metrics.id)}

  let!(:influence_industry2) { create(:influence_industry,
                                     industry_name: 'industry2',
                                     industry_score: '12',
                                     avg_posts: '3',
                                     avg_comments: '2',
                                     avg_likes: '1.2342',
                                     influence_metric_id: influence_metrics.id)}

  let!(:kol2) { create(:kol)}
  let!(:kol2_identity) { create(:identity, kol_id: kol2.id, provider: 'weibo', uid: 'weibo_kol2', avatar_url: 'http://user2_avatar')}
  let!(:kol2_influence_metrics) { create(:influence_metric,
                                    calculated: true,
                                    provider: 'weibo',
                                    kol_id: kol2.id,
                                    influence_score: '88',
                                    avg_posts: '1234',
                                    avg_comments: '2342',
                                    avg_likes: '232.3542345')}
  let!(:kol2_influence_industry1) { create(:influence_industry,
                                      industry_name: 'industry1',
                                      industry_score: '3000', # which is more than 'industry1' for main kol
                                      avg_posts: '134',
                                      avg_comments: '134',
                                      avg_likes: '23423.4534',
                                      influence_metric_id: kol2_influence_metrics.id)}

  # Kol with lower influence in industry than "our" kol
  let!(:kol3) { create(:kol)}
  let!(:kol3_identity) { create(:identity, kol_id: kol3.id, provider: 'weibo', uid: 'weibo_kol3', avatar_url: 'http://user3_avatar')}
  let!(:kol3_influence_metrics) { create(:influence_metric,
                                         calculated: true,
                                         provider: 'weibo',
                                         kol_id: kol3.id,
                                         influence_score: '88',
                                         avg_posts: '1234.32452',
                                         avg_comments: '2342.35345',
                                         avg_likes: '232.243534')}
  let!(:kol3_influence_industry1) { create(:influence_industry,
                                           industry_name: 'industry1',
                                           industry_score: '100', # which is LESS than 'industry1' for main kol
                                           avg_posts: '134',
                                           avg_comments: '134',
                                           avg_likes: '23423.4444444444',
                                           influence_metric_id: kol3_influence_metrics.id)}


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
      expect(res['influence_score_visibility']).to eq true
      # expect(res['influence_level']).to eq '影响力优秀'
      expect(res['influence_score_percentile']).to eq '超过0%的用户'
      expect(res['industries'].size).to eq 2

      similar_kols = res['similar_kols']
      expect(similar_kols.size).to eq 1
      expect(similar_kols.first['id']).to eq kol2.id
      expect(similar_kols.first['avatar_url']).to eq 'http://user2_avatar'
    end

    describe 'with other kol who does not allow to see his influence score' do
      before do
        kol2.update_attributes(influence_score_visibility: false)
      end

      it 'does not return this kol data' do
        get '/api/v2_0/kols/influence_score'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['similar_kols'].size).to eq 0
      end
    end

    describe 'when kol has empty influence industries' do
      let!(:kol_empty) { create(:kol)}
      let!(:identity_empty) { create(:identity, kol_id: kol_empty.id, provider: 'weibo', uid: 'weibo_empty')}
      let!(:influence_metrics_empty) { create(:influence_metric,
                                        calculated: true,
                                        provider: 'weibo',
                                        kol_id: kol_empty.id,
                                        influence_score: '88',
                                        avg_posts: '1234',
                                        avg_comments: '2342',
                                        avg_likes: '232')}

      before do
        Grape::Endpoint.before_each do |endpoint|
          allow(endpoint).to receive(:current_kol).and_return(kol_empty)
        end
      end

      it 'returns empty industry influence list' do
        get '/api/v2_0/kols/influence_score'
        expect(response.status).to eq 200

        res = JSON.parse(response.body)
        expect(res['error']).to eq 0
        expect(res['calculated']).to eq true
        expect(res['industries'].size).to eq 0
      end
    end

    it 'returns valid json for other kol IDs' do
      get "/api/v2_0/kols/#{kol2.id}/similar_kol_details"
      expect(response.status).to eq 200

      res = JSON.parse(response.body)
      expect(res['error']).to eq 0
      expect(res['calculated']).to eq true
      # expect(res['influence_level']).to eq '影响力优秀'
      expect(res['influence_score_percentile']).to eq '超过0%的用户'
      expect(res['industries'].size).to eq 1
    end
  end

end
