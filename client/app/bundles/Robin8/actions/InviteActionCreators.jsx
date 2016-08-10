import actionTypes from '../constants/brandConstants';
import _ from "lodash";

const baseUrl = "/brand_api/v1"

export function saveInvite(campaign) {
  var formData = new FormData()

  _.forEach(campaign, (value, key) => {
    if (key == 'material_ids' && !value) {
      return;
    }

    formData.append(key, value);
  });

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

export function updateInvite(campaign_id, campaign) {
  var formData = new FormData()

  _.forEach(campaign, (value, key) => {
    if (key == 'material_ids' && !value) {
      return;
    }

    formData.append(key, value);
  });

  return {
    type: actionTypes.UPDATE_INVITE_CAMPAIGN,
    promise: fetch(
      `${baseUrl}/invite_campaigns/${campaign_id}`, {
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

export function fetchInvite(id) {
  return {
    type: actionTypes.FETCH_INVITE_CAMPAIGN,
    promise: fetch(`${baseUrl}/invite_campaigns/${id}`, { "credentials": 'same-origin' })
  };
}

export function fetchAgreedInvitesOfInviteCampaign(id) {
  return {
    type: actionTypes.FETCH_AGREED_INVITES_OF_INVITE_CAMPAIGN,
    promise: fetch(`/brand_api/v1/invite_campaigns/${id}/agreed_invites`, {"credentials": "same-origin"})
  }
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
