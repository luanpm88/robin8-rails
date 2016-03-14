import React from 'react'
import { Route, IndexRoute } from 'react-router'
import BrandHomeContainer from '../containers/BrandHomeContainer'
import CreateActivityPartial from '../components/CreateActivityPartial'
import BrandHomePartial from '../components/BrandHomePartial'


export default (
  <Route path="/brand/" component={BrandHomeContainer}>
    <IndexRoute component={BrandHomePartial} />

    <Route path="create_activity" component={CreateActivityPartial} />
  </Route>
)
