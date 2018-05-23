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
      case 'url':
        const regex = /^http|https:\/\//
        if (regex.test(campaign.url)) {
          formData.append(`${key}`, campaign[key])
        }
        else {
          formData.append(`${key}`, 'http://' + campaign[key])
        }
      case 'age':
      case 'gender':
      case 'region':
      case 'tags':
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

export function clearCampaign() {
  return {
    type: actionTypes.CLEAR_CAMPAIGN
  };
}

export function updateCampaign(campaign_id, campaign) {
  var formData = new FormData()
  for(let key of Object.keys(campaign)) {
    switch(key) {
      case 'url':
        const regex = /^http|https:\/\//
        if (regex.test(campaign.url)) {
          formData.append(`${key}`, campaign[key])
        }
        else {
          formData.append(`${key}`, 'http://' + campaign[key])
        }
      case 'age':
      case 'gender':
      case 'region':
      case 'tags':
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
    redirect: '/brand/campaigns/:id/preview'
  };
}

export function updateCampaignBase(campaign_id, campaign) {
  var formData = new FormData()
  for(let key of Object.keys(campaign)) {
    switch(key) {
      case 'url':
        const regex = /^http|https:\/\//
        if (regex.test(campaign.url)) {
          formData.append(`${key}`, campaign[key])
        }
        else {
          formData.append(`${key}`, 'http://' + campaign[key])
        }
      default:
        formData.append(`${key}`, campaign[key]);
        break;
    }
  }

  return {
    type: actionTypes.UPDATE_CAMPAIGN_BASE,
    promise: fetch(
      `${baseUrl}/campaigns/${campaign_id}/edit_base`, {
        headers: {
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
        },
        credentials: "same-origin",
        method: 'PUT',
        body: formData
      }
    ),
    redirect: '/brand/campaigns/:id/preview'
  };
}

export function evaluateCampaign(campaign_id, campaign) {
  var formData = new FormData()
  for(let key of Object.keys(campaign)) {
    switch(key) {
      default:
        formData.append(`${key}`, campaign[key]);
        break;
    }
  }

  return {
    type: actionTypes.EVALUATE_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/campaigns/${campaign_id}/evaluate`, {
        headers: {
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
        },
        credentials: "same-origin",
        method: 'PUT',
        body: formData
      }
    ),
    redirect: `/brand/campaigns/${campaign_id}`
  };
}

export function fetchCampaign(id) {
  return {
    type: actionTypes.FETCH_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaigns/${id}`, { "credentials": 'same-origin' })
  };
}

export function goPayCampaign(campaign_id) {
  const data = { campaign_id };

  return {
    type: actionTypes.GO_PAY_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/campaigns/${campaign_id}/lock_budget`, {
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
    redirect: `/brand/campaigns/${campaign_id}/pay`
  };
}

export function payCampaignByBalance(campaign_id, use_credit) {
  const data = { campaign_id, pay_way: "balance", use_credit: use_credit };
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

export function payCampaignByAlipay(campaign_id, use_credit) {
  const data = { campaign_id, use_credit: use_credit };
  return {
    type: actionTypes.PAY_CAMPAIGN_BY_ALIPAY,
    promise: fetch(
      `${baseUrl}/campaigns/${campaign_id}/pay_by_alipay`, {
        headers: {
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content'),
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        credentials: "same-origin",
        method: 'POST',
        body: JSON.stringify(data)
      }
    )
  };
}

export function revokeCampaign(campaign_id) {
  const data = { campaign_id };
  return {
    type: actionTypes.REVOKE_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/campaigns/${campaign_id}/revoke_campaign`, {
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

export function fetchInstallsOfCampaign(campaign_id){
  return {
    type: actionTypes.FETCH_INSTALLS_OF_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaigns/installs?campaign_id=${campaign_id}`, {"credentials": "include"})
  };
}

export function analysisCampaign(url){
  var formData = new FormData()
  formData.append("url", url)

  return {
    type: actionTypes.ANALYSIS_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaigns/analysis`, {
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content'),
      },
      credentials: "same-origin",
      method: 'POST',
      body: formData
    })
  }
}

export function analysisBuildCampaign(url, type){
  var formData = new FormData()
  formData.append("url", url);
  formData.append("per_budget_type", type);

  return {
    type: actionTypes.ANALYSIS_BUILD_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaigns/analysis_build`, {
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content'),
      },
      credentials: "same-origin",
      method: 'POST',
      body: formData
    })
  }
}

export function AnalysisInvitesOfCampaign(campaign_id){
  return {
    type: actionTypes.ANALYSIS_INVITES_OF_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaign_invites/analysis?campaign_id=${campaign_id}`, {'credentials': 'include'})
  }
}

export function clearAnalysisCampaign() {
  return {
    type: actionTypes.CLEAR_ANALYSIS_CAMPAIGN
  };
}

export function clearCampaignInput() {
  return {
    type: actionTypes.CLEAR_CAMPAIGN_INPUT
  };
}
