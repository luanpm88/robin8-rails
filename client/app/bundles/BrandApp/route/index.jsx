import React from 'react';
import { Route, IndexRoute } from 'react-router';
import Layout from '../containers/BrandApp';
import HomePartial from '../components/HomePartial';
import CreateActivityPartial from '../components/CreateActivityPartial';

/*
 路由的配置
 https://github.com/reactjs/react-router/blob/master/docs/guides/RouteConfiguration.md
*/
export default (
  <Route path="/react/" component={Layout}>
    <IndexRoute component={HomePartial} />

    <Route path="create_activity" component={CreateActivityPartial} />
  </Route>
);