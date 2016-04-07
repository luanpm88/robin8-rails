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

export function fetchBrandProfile() {
  return {
    type: actionTypes.FETCH_BRAND_PROFILE,
    promise: fetch('/brand_api/v1/user', { credentials: 'same-origin' })
  };
}

export function updateBrandProfile(profile) {
  return {
    type: actionTypes.UPDATE_BRAND_PROFILE,
    promise: fetch(`${baseUrl}/user`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'PUT',
      body: JSON.stringify(profile)
    }),
    redirect: '/brand/'
  }
}

export function updateBrandPassword(password_fields) {
  return {
    type: actionTypes.UPDATE_BRAND_PASSWORD,
    promise: fetch(`/brand_api/v1/user/password`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'PUT',
      body: JSON.stringify(password_fields)
    })
  }
}
