import { browserHistory } from 'react-router'

export default function promiseMiddleware() {
  return next => action => {
    const { promise, redirect, ...rest } = action;

    if (!promise) {
      return next(action);
    }

    next({ ...rest, readyState: 'request' });

    return promise.then((response) => {
      if (response.status >= 200 && response.status < 300) {
        return response
      } else {
        const error = new Error(response.statusText)
        error.response = response
        throw error
      }

    }).then( (response) => {
      return response.json()
    }).then( (json) => {

        // 成功后的跳转
        if (redirect) {
          browserHistory.push(redirect)
        }
        return next({ ...rest, result: json, readyState: 'success' })
      }
    )['catch']( error => {
      error.response.json().then( (json) => {
        if(Array.isArray(json.detail)){
          if (json.detail[0] == "amount_not_engouh") {
            $(".brand-error-notice-modal .modal-body p").html("账号余额不足, 请");
            $(".brand-error-notice-modal .modal-body p").append("<span class='recharge'><a href='/contact?from=recharge' target='_blank'>充值</a></span>")
            $(".brand-error-notice-modal .modal-title").html("保存失败");
            $(".brand-error-notice-modal").modal("show");
          }
        } else if(json.error == 'Access Denied') {
          browserHistory.push('/brand/');  //若没有权限做某事, 则跳转到首页
        } else {
          $(".brand-error-notice-modal .modal-body p").html(json.detail);
          $(".brand-error-notice-modal .modal-title").html("保存失败");
          $(".brand-error-notice-modal").modal("show");
        }
      })
      return next({ ...rest, readyState: 'failure'})
    });
  };
}
