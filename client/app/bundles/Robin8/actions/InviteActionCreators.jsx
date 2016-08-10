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

