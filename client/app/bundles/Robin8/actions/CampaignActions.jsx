import actionTypes from '../constants/brandConstants';

const baseUrl = "/brand_api/v1"
export function fetchCampaigns(current_page) {
  return {
    type: actionTypes.FETCH_CAMPAIGNS,
    promise: fetch(`${baseUrl}/user/campaigns?page=${current_page.page}`, { credentials: 'same-origin' })
  };
}

export function saveCampaign(campaign) {
  var formData = new FormData()

  for(let key of Object.keys(campaign)) {
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
    formData.append("target[region]", (campaign['province'] + " " + campaign['city']))
  }

  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/campaigns`, {
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
