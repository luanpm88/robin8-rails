import actionTypes from '../constants/brandConstants';

const baseUrl = "/brand_api/v1"

export function saveInvite(campaign) {
  var formData = new FormData()

  for(let key of Object.keys(campaign)) {
    formData.append(`${key}`, campaign[key]);
  }

  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/invite_campaigns`, {
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

export function updateSearchKolsCondition(condition){
  return {
    type: actionTypes.UPDATE_SEARCH_KOLS_CONDITION,
    data: condition
  };
}

export function searchKolsInCondition(condition, page = 1){
  const region = condition.get("region");
  return {
    type: actionTypes.SEARCH_KOLS_IN_CONDITION,
    promise: fetch(`${baseUrl}/kols/search?page=${page}&region=${region}`, {"credentials": "include"})
  };
}

export function addSelectedKol(kol){
  return {
    type: actionTypes.ADD_SELECTED_KOL,
    data: kol
  };
}

export function removeSelectedKol(kol){
  return {
    type: actionTypes.REMOVE_SELECTED_KOL,
    data: kol
  };
}