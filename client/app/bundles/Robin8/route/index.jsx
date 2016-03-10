import React from 'react'
import { Route, IndexRoute } from 'react-router'
import BrandHomeContainer from '../containers/BrandHomeContainer'
import CampaignList from '../components/brand_home/CampaignList'

export default (
  <Route path="/brand/" component={BrandHomeContainer}>
    <IndexRoute component={CampaignList} />
  </Route>
)
