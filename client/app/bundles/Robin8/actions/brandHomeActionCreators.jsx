console.log("begin brandHomeActionCreators");

import actionTypes from '../constants/BrandHomeConstants'

const CAMPAIGNS_URL = 'brand_api/v1/user/campaigns'

export function fetchCampaigns(currentPage) {

  return {
    type: actionTypes.FETCH_CAMPAIGNS,
    promise: fetch(CAMPAIGNS_URL + "?page=" + currentPage.page)
  };
}


console.log("after brandHomeActionCreators");
