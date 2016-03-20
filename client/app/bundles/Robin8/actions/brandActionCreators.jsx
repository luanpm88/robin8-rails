import actionTypes from '../constants/brandConstants';

const CAMPAIGNS_URL = '/brand_api/v1/user/campaigns';
const SAVE_CAMPAIGN_URL = '/brand_api/v1/campaigns';

export function fetchCampaigns(currentPage) {

  return {
    type: actionTypes.FETCH_CAMPAIGNS,
    promise: fetch(CAMPAIGNS_URL + "?page=" + currentPage.page, { credentials: 'include' })
  };
}

export function saveCampaign(campaign) {
  var formData = new FormData()

  for(let key of Object.keys(campaign)) {
    if (campaign[key] && campaign[key].constructor.name === 'FileList') {
      formData.append(`${key}`, campaign[key][0])
    } else {
      switch(key) {
        case 'age':
          campaign[key] = campaign[key] || $('.age-range').val()
          formData.append("target[age]", campaign[key]);
          break;
        case 'province':
          campaign[key] = campaign[key] || $('.province').val()
          break;
        case 'city':
          campaign[key] = campaign[key] || $('.city').val()
          break;
        case 'gender':
          campaign[key] = campaign[key] || $('.gender').val()
          formData.append("target[gender]", campaign[key]);
          break;
        case 'start_time':
          campaign[key] = campaign[key] || $("#start-time-datepicker").val()
          formData.append(`${key}`, campaign[key]);
          break;
        case 'deadline':
          campaign[key] = campaign[key] || $("#deadline-datepicker").val()
          formData.append(`${key}`, campaign[key]);
          break;
        case 'per_budget_type':
          campaign[key] = campaign[key] || $('input:radio[name="action_type"]:checked').val()
          formData.append(`${key}`, campaign[key]);
          break;
        case 'action_url':
        case 'short_url':
        case 'action_url_identifier':
          campaign[key] = campaign[key]
          formData.append(`campaign_action_url[${key}]`, campaign[key]);
          break;
        default:
          formData.append(`${key}`, campaign[key]);
          break;
      }
    }
    formData.append("target[region]", (campaign['province'] + " " + campaign['city']))
  }


  return {
    type: actionTypes.SAVE_CAMPAIGN,
    promise: fetch(
      SAVE_CAMPAIGN_URL, {
        headers: {
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
        },
        credentials: "same-origin",
        method: 'post',
        body: formData
      }
    ),
    redirect: '/brand/'
  };
}
