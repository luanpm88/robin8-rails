console.log("in BrandHomeAppClient");

import React from 'react'
import { Provider } from 'react-redux'
import { Router, browserHistory } from 'react-router'
import { syncHistoryWithStore } from 'react-router-redux'
import createStore from '../store/Robin8Store'
import BrandHomeContainer from '../containers/BrandHomeContainer'
import routes from '../route'

function logger_location_path(location){
  //https://github.com/reactjs/react-router-redux#how-do-i-watch-for-navigation-events-such-as-for-analytics
  //后期可以考虑加入middleware 来监听变化
  console.log("------logger location-------");
  console.log(location.pathname);
  console.log("------end-----");
}

export default (props) => {
  const store = createStore(props);

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
