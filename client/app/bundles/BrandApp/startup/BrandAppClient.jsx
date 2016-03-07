import React from 'react';
import { Provider } from 'react-redux';
import createStore from '../store/BrandStore';
import BrandApp from '../containers/BrandApp';

import { Router, browserHistory } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';

import routes from '../route';

function logger_location_path(location){
  //https://github.com/reactjs/react-router-redux#how-do-i-watch-for-navigation-events-such-as-for-analytics
  //后期可以考虑加入middleware 来监听变化
  console.log("------logger location-------");
  console.log(location.pathname);
  console.log("------end-----");
}

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
  
  history.listen(location => 
    logger_location_path(location)
  );

  return <Provider store={store}>
    <Router history={history} children={routes} />
  </Provider>;
};
