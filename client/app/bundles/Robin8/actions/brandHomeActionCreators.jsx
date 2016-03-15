console.log("begin brandHomeActionCreators");

import actionTypes from '../constants/BrandHomeConstants'

const CAMPAIGNS_URL = '/brand_api/v1/user/campaigns'
const SAVE_CAMPAIGN_URL = 'campaign'

export function fetchCampaigns(currentPage) {

  return {
    type: actionTypes.FETCH_CAMPAIGNS,
    promise: fetch(CAMPAIGNS_URL + "?page=" + currentPage.page, { credentials: 'include' })
  };
}

export function saveCampaign(campaign) {
  var formData = new FormData()

  for(let key of Object.keys(campaign)) {
    if (campaign[key] && campaign[key].constructor.name === 'FileList') {
      formData.append(`campaign[${key}]`, campaign[key][0])
    } else {
      if (key == "start_time") {
        campaign[key] = campaign[key] || $("#start-time-datepicker").val()
      } else if(key == "deadline") {
        campaign[key] = campaign[key] || $("#deadline-datepicker").val()
      } else if (key == "budget") {
        campaign[key] = campaign[key] || $(".budget-input").val()
      }

      formData.append(`campaign[${key}]`, campaign[key]);
    }
  }

  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch(
      '/campaign', {
        headers: {
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
        },
        credentials: "same-origin",
        method: 'post',
        body: formData
      }
    ),
    redirect: '/brand/'
  };
}


console.log("after brandHomeActionCreators");
