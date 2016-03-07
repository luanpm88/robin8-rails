import request from 'axios'

const EMAIL_URL = 'get_current_user_email'

export default {
  fetchEntities() {
    return request({
      method: 'GET',
      url: EMAIL_URL,
      responseType: 'json'
    });
  }
};
