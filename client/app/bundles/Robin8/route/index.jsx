import React from 'react';
import { Route, IndexRoute } from 'react-router';
import BrandHomeContainer from '../containers/BrandHomeContainer';
import CreateCampaignPartial from '../components/CreateCampaignPartial';
import UpdateCampaignPartial from '../components/UpdateCampaignPartial';
import BrandHomePartial from '../components/BrandHomePartial';
import ShowCampaignPartial from '../components/ShowCampaignPartial';
import ShowRecruitCampaignPartial from '../components/ShowRecruitCampaignPartial';
import EditProfilePartial from '../components/EditProfilePartial';
import UpdatePasswordPartial from '../components/UpdatePasswordPartial';
import CreateRecruitCampaignPartial from '../components/CreateRecruitCampaignPartial';

export default (
  <Route path="/brand" component={BrandHomeContainer}>
    <IndexRoute component={BrandHomePartial} />

    <Route path="campaigns/new" component={CreateCampaignPartial} />
    <Route path="recruits/new" component={CreateRecruitCampaignPartial} />
    <Route path="campaigns/:id/edit" component={UpdateCampaignPartial} />
    <Route path="campaigns/:id" component={ShowCampaignPartial} />
    <Route path="recruits/:id" component={ShowRecruitCampaignPartial} />
    <Route path=":id/edit" component={EditProfilePartial} />
    <Route path="password" component={UpdatePasswordPartial} />
  </Route>
)
