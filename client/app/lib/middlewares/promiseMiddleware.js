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
      const response = error.response;

      error.response.json().then( (json) => {

        // 自定义报错方式
        alert(json.error)
      })

      next({ ...rest, readyState: 'failure' })
    });
  };
}