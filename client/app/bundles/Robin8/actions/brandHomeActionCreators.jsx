console.log("begin brandHomeActionCreators");

import requestsEmail from 'lib/requestsManager';
import requestCampaignList from 'lib/requestCampaignList';
import actionTypes from '../constants/brandHomeConstants'

export function setIsFetching() {
  console.log("in setIsFetching");
  return {
    type: actionTypes.SET_IS_FETCHING
  };
}

export function fetchCampaignListSuccess(campaignList) {
  console.log("in fetchCampaignListSuccess");

  return {
    type: actionTypes.FETCH_CAMPAIGN_LIST_SUCCESS,
    campaignList
  };
}

export function fetchCampaignListFailure(error) {
  console.log("in fetchCampaignListFailure");

  return {
    type: actionTypes.FETCH_CAMPAIGN_LIST_FAILURE,
    error
  };
}

export function fetchCampaignList() {
  console.log("innnnnnn fetchCampaignList");
  return dispatch => {
    dispatch(setIsFetching());

    return (
      requestCampaignList
        .fetchCampaignList()
        .then(res => dispatch(fetchCampaignListSuccess(res.data)))
        .catch(res => dispatch(fetchCampaignListFailure(res.data)))
    );
  };
}

console.log("after brandHomeActionCreators");
