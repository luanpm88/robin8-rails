console.log("begin brandHomeActionCreators");

import actionTypes from '../constants/BrandHomeConstants'

const CAMPAIGNS_URL = '/brand_api/v1/user/campaigns'
const SAVE_CAMPAIGN_URL = '/brand_api/v1/campaigns'

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
      switch(key) {
        case 'age':
          campaign[key] = campaign[key] || $('.age-range').val()
          break;
        case 'province':
          campaign[key] = campaign[key] || $('.province').val()
          break;
        case 'city':
          campaign[key] = campaign[key] || $('.city').val()
          break;
        case 'sex':
          campaign[key] = campaign[key] || $('.sex').val()
          break;
        case 'start_time':
          campaign[key] = campaign[key] || $("#start-time-datepicker").val()
          break;
        case 'deadline':
          campaign[key] = campaign[key] || $("#deadline-datepicker").val()
          break;
        case 'budget':
          campaign[key] = campaign[key] || $(".budget-input").val()
          break;
        case 'per_action_budget':
          campaign[key] = campaign[key] || $(".per-budget-input").val()
          break;
      }
      formData.append(`campaign[${key}]`, campaign[key]);
    }
  }


  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch(
      SAVE_CAMPAIGN_URL, {
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
