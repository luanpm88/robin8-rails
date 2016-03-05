import { actionTypes } from '../constants';

export function requestCampaigns() {
  return {
    type: actionTypes.REQUEST_CAMPAIGNS,
    promise: fetch('http://localhost:3000/react_fake_data/campaigns.json')
  };
}

export function saveCampaign(data) {
  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch('http://localhost:3000/react_fake_data/campaigns.json')
  };
}
