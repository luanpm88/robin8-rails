import request from 'axios'

const CAMPAIGN_LIST_URL = 'brand_api/v1/user/campaigns'

export default {
  fetchCampaignList() {
    return request({
      method: 'GET',
      url: CAMPAIGN_LIST_URL,
      responseType: 'json'
    });
  }
};
