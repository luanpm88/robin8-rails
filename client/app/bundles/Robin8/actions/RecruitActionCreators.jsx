import actionTypes from '../constants/brandConstants';

const baseUrl = "/brand_api/v1"

export function saveRecruit(campaign) {
  var formData = new FormData()

  for(let key of Object.keys(campaign)) {
    switch(key){
      case "region":
        if(campaign[key] == undefined || campaign[key] == "请选择地区"){
          formData.append(`${key}`, "全部");
        }else{
          formData.append(`${key}`, campaign[key]);
        }
        break
      case 'material_ids':
        if(campaign[key] === undefined) {
          break
        }
      default:
        formData.append(`${key}`, campaign[key]);
    }
  }

  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/recruit_campaigns`, {
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

export function updateRecruit(campaign_id, campaign) {
  var formData = new FormData()

  for(let key of Object.keys(campaign)) {
    switch(key){
      case "region":
        if(campaign[key] == undefined || campaign[key] == "请选择地区"){
          formData.append(`${key}`, "全部");
        }else{
          formData.append(`${key}`, campaign[key]);
        }
        break
      case 'material_ids':
        if(campaign[key] === undefined) {
          break
        }
      default:
        formData.append(`${key}`, campaign[key]);
    }
  }

  return {
    type: actionTypes.UPDATE_RECRUIT,
    promise: fetch(
      `${baseUrl}/recruit_campaigns/${campaign_id}`, {
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

export function fetchRecruit(id) {
  return {
    type: actionTypes.FETCH_RECRUIT_CAMPAIGN,
    promise: fetch(`${baseUrl}/recruit_campaigns/${id}`, { "credentials": 'same-origin' })
  };
}

export function fetchAppliesOfRecruit(campaign_id, current_page){
  return {
    type: actionTypes.FETCH_APPLIES_OF_RECRUIT_CAMPAIGN,
    promise: fetch(`${baseUrl}/campaign_applies?campaign_id=${campaign_id}&page=${current_page.page}`, {'credentials': 'include'})
  }
}

export function updateRecruitCompaignKols(campaign_id) {
  return {
    type: actionTypes.UPDATE_RECRUIT_CAMPAIGN_KOLS,
    promise: fetch(`${baseUrl}/recruit_campaigns/${campaign_id}/end_apply_check`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'PUT'
    })
  }
}

export function passAllKols(campaign_id) {
  return {
    type: actionTypes.PASS_RECRUIT_CAMPAIGN_ALL_KOLS,
    promise: fetch(`${baseUrl}/campaign_applies/${campaign_id}/pass_all_kols`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'PUT'
    })
  }
}

export function updateRecruitCompaignKolStatus(campaign_id, kol_id, index, status) {
  const data = { campaign_id, kol_id, status };

  return {
    type: actionTypes.UPDATE_RECRUIT_CAMPAIGN_KOL_STATUS,
    index: index,
    promise: fetch(`${baseUrl}/campaign_applies/change_status`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'PUT',
      body: JSON.stringify(data)
    })
  }
}

export function fetchRecruitCampaignMaterials(campaign_id) {
  return {
    type: actionTypes.FETCH_RECRUIT_CAMPAIGN_MATERIALS,
    promise: fetch(`${baseUrl}/campaign_materials?campaign_id=${campaign_id}`, { "credentials": 'same-origin' })
  };
}

export function updateKolScoreAndBrandOpinionOfRecruit(campaign_id, kol_id, index, score, opinion = "") {
  const data = {campaign_id, kol_id, score, opinion};

  return {
    type: actionTypes.UPDATE_KOL_SCORE_AND_BRAND_OPINION_OF_RECRUIT,
    index: index,
    promise: fetch(`${baseUrl}/campaign_applies/update_score_and_opinion`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'PUT',
      body: JSON.stringify(data)
    })
  }
}
