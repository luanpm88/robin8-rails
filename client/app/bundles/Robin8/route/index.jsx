import React from 'react';
import { Route, IndexRoute } from 'react-router';
import BrandHomeContainer from '../containers/BrandHomeContainer';
import CreateCampaignPartial from '../components/CreateCampaignPartial';
import UpdateCampaignPartial from '../components/UpdateCampaignPartial';
import BrandHomePartial from '../components/BrandHomePartial';
import ShowActivityPartial from '../components/ShowActivityPartial';
import EditProfilePartial from '../components/EditProfilePartial';

export default (
  <Route path="/brand/" component={BrandHomeContainer}>
    <IndexRoute component={BrandHomePartial} />

    <Route path="create_campaign" component={CreateCampaignPartial} />
    <Route path="campaigns/:id/edit" component={UpdateCampaignPartial} />
    <Route path="campaigns/:id" component={ShowActivityPartial} />

    <Route path=":id/edit" component={EditProfilePartial} />
  </Route>
)
