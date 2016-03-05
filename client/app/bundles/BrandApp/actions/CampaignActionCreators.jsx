import { actionTypes } from '../constants';
import { browserHistory } from 'react-router'

export function requestCampaigns() {
  return {
    type: actionTypes.REQUEST_CAMPAIGNS,
    promise: fetch('http://localhost:3000/react_fake_data/campaigns.json')
  };
}

// 因为有文件，所以用multipart/form-data
export function saveCampaign(data) {
  var formData = new FormData();

  for (var key of Object.keys(data)) {
    if (data[key] && data[key].constructor.name === 'FileList') {
      formData.append(`data[${key}]`, data[key][0]);
    } else {
      formData.append(`data[${key}]`, data[key]);
    }
  }

  browserHistory.push('/react/')

  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch(
      'http://localhost:3000/react_fake_data/campaigns.json', {
        method: 'post',
        body: formData
      })
  };
}
