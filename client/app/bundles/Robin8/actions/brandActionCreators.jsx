import actionTypes from '../constants/brandConstants';

const CAMPAIGNS_URL = '/brand_api/v1/user/campaigns';
const SAVE_CAMPAIGN_URL = '/brand_api/v1/campaigns';

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
      formData.append(`${key}`, campaign[key][0])
    } else {
      switch(key) {
        case 'age':
        case 'gender':
          formData.append(`target[${key}]`, campaign[key]);
          break;
        case 'action_url':
        case 'short_url':
        case 'action_url_identifier':
          formData.append(`campaign_action_url[${key}]`, campaign[key]);
          break;
        default:
          formData.append(`${key}`, campaign[key]);
          break;
      }
    }
    formData.append("target[region]", (campaign['province'] + " " + campaign['city']))
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

export function fetchCampaign(id) {
  return {
    type: actionTypes.FETCH_CAMPAIGN,
    promise: fetch(`/brand_api/v1/campaigns/${id}`, { credentials: 'include' })
  };
}
