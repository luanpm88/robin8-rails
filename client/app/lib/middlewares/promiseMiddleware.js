export default function promiseMiddleware() {
  return next => action => {
    const { promise, ...rest } = action;

    if (!promise) {
      return next(action);
    }

    next({ ...rest, readyState: 'request' });

    return promise.then(response => response.json()).then(
      (json) => {
        next({ ...rest, result: json, readyState: 'success' })
      },
      (error) => next({ ...rest, error, readyState: 'failure' })
    );
  };
}