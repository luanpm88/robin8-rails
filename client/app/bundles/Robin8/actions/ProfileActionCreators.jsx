import actionTypes from '../constants/brandConstants';

const baseUrl = "/brand_api/v1"

export function fetchBrandProfile() {
  return {
    type: actionTypes.FETCH_BRAND_PROFILE,
    promise: fetch(`${baseUrl}/user`, { credentials: 'same-origin' })
  };
}

export function fetchBrandPromotion() {
  return {
    type: actionTypes.FETCH_BRAND_PROMOTION,
    promise: fetch(`${baseUrl}/user/promotion`, { credentials: 'same-origin' })
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
    promise: fetch(`${baseUrl}/user/password`, {
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
