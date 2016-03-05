import React from 'react';
import { Provider } from 'react-redux';
import createStore from '../store/BrandStore';
import BrandApp from '../containers/BrandApp';

import { Router, browserHistory } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';

import routes from '../route';

// 这里的props是 Rails helper react_component 传进来的 props
export default (props) => {
  const store = createStore(props);

  // console.log(store.getState());
  // let unsubscribe = store.subscribe(() =>
  //   console.log(store.getState())
  // );

  const history = syncHistoryWithStore(
    browserHistory,
    store
  );

  return <Provider store={store}>
    <Router history={history} children={routes} />
  </Provider>;
};
