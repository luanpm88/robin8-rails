import { browserHistory } from 'react-router'

export default function promiseMiddleware() {
  return next => action => {
    const { promise, redirect, ...rest } = action;

    if (!promise) {
      return next(action);
    }

    next({ ...rest, readyState: 'request' });

    return promise.then(response => response.json()).then(
      (json) => {

        // 成功后的跳转
        if (redirect) {
          browserHistory.push(redirect)
        }

        next({ ...rest, result: json, readyState: 'success' })
      },
      (error) => next({ ...rest, error, readyState: 'failure' })
    );
  };
}