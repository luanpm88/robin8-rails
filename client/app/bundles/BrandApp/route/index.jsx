import React from 'react';
import { Route, IndexRoute } from 'react-router';
import Layout from '../containers/BrandApp';
import HomePartial from '../components/HomePartial';
import CreateActivityPartial from '../components/CreateActivityPartial';

export default (
  <Route path="/react/" component={Layout}>
    <IndexRoute
      component={HomePartial}
    />

    {/*<Route path="create_activity" component={CreateActivityPartial} />*/}

    {/*// <Route
    //   path="react-router"
    //   component={TestReactRouter}
    // />
    // <Route
    //   path="react-router/redirect"
    //   component={TestReactRouterRedirect}
    //   onEnter={TestReactRouterRedirect.checkAuth}
    // />*/}
  </Route>
);