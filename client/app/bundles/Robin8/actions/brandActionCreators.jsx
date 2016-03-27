import actionTypes from '../constants/brandConstants';

export function fetchCampaigns(current_page) {

  return {
    type: actionTypes.FETCH_CAMPAIGNS,
    promise: fetch(`/brand_api/v1/user/campaigns?page=${current_page.page}`, { credentials: 'same-origin' })
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
      '/brand_api/v1/campaigns', {
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
    type: actionTypes.UPDATE_CAMPAIGN,
    promise: fetch(
      `/brand_api/v1/campaigns/${campaign_id}`, {
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
    promise: fetch(`/brand_api/v1/campaigns/${id}`, { credentials: 'same-origin' })
  };
}

export function fetchBrandProfile() {
  return {
    type: actionTypes.FETCH_BRAND_PROFILE,
    promise: fetch('/brand_api/v1/user', { credentials: 'same-origin' })
  };
}

export function updateBrandProfile(profile) {
  var formData = new FormData()
  for(let key of Object.keys(profile)) {
    formData.append(`${key}`, profile[key])
  }

  return {
    type: actionTypes.UPDATE_BRAND_PROFILE,
    promise: fetch('/brand_api/v1/user', {
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'PUT',
      body: formData
    }),
    redirect: '/brand/'
  }
}
