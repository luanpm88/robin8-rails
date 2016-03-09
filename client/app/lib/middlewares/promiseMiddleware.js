import { browserHistory } from 'react-router'

export default function promiseMiddleware() {
  return next => action => {
    const { promise, redirect, ...rest } = action;

    if (!promise) {
      return next(action);
    }

    next({ ...rest, readyState: 'request' });

    return promise.then((response) => {

      // http Code Error
      if (!response.ok) {
        next({ ...rest, readyState: 'failure' })
        throw Error(response.statusText);
      }

      return response.json();
    }).then( (json) => {
        // 服务器返回，需要有一个固定的key，这里暂定success
        if (json.success) {

          // 成功后的跳转
          if (redirect) {
            browserHistory.push(redirect)
          }

          next({ ...rest, result: json, readyState: 'success' })
        } else {

          // 自定义报错方式
          alert(json.error)

          next({ ...rest, readyState: 'failure' })
        }
      }
    )['catch']( error => {
      console.log(error);
    });
  };
}
