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

export function searchKolsInCondition(condition, page = 1){
  let params = [ `page=${page}` ];
  _.forIn(condition, (value, key) => params.push(`${key}=${value}`));

  const queryString = params.join("&");
  return {
    type: actionTypes.SEARCH_KOLS_IN_CONDITION,
    promise: fetch(`${baseUrl}/social_accounts/search?${queryString}`, {"credentials": "include"})
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