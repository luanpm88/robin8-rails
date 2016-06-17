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
    redirect: '/brand/campaigns/:id/preview'
  };
}

export function updateCampaign(campaign_id, campaign) {
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
    type: actionTypes.UPDATE_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/campaigns/${campaign_id}`, {
        headers: {
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
        },
        credentials: "same-origin",
        method: 'PUT',
        body: formData
      }
    ),
    redirect: '/brand/'
  };
}

export function fetchCampaign(id) {
  return {
    type: actionTypes.FETCH_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaigns/${id}`, { "credentials": 'same-origin' })
  };
}

export function payCampaignByBalance(campaign_id) {
  const data = { campaign_id, pay_way: "balance" };
  return {
    type: actionTypes.PAY_CAMPAIGN_BY_BALANCE,
    promise: fetch(
      `${baseUrl}/campaigns/${campaign_id}/pay_by_balance`, {
        headers: {
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content'),
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        credentials: "same-origin",
        method: 'PATCH',
        body: JSON.stringify(data)
      }
    ),
    redirect: '/brand/'
  };
}

export function fetchInvitesOfCampaign(campaign_id, current_page){
  return {
    type: actionTypes.FETCH_INVITES_OF_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaign_invites?campaign_id=${campaign_id}&page=${current_page.page}`, {'credentials': 'include'})
  }
}

export function fetchStatisticsClicksOfCampaign(campaign_id){
  return {
    type: actionTypes.FETCH_STATISTICS_CLICKS_OF_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaigns/statistics_clicks?campaign_id=${campaign_id}`, {"credentials": "include"})
  };
}
