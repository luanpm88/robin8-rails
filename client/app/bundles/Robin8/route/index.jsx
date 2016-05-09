import React from 'react';
import { Route, IndexRoute } from 'react-router';
import BrandHomeContainer from '../containers/BrandHomeContainer';
import BrandHomePartial from '../components/BrandHomePartial';

export default (
  <Route path="/brand" component={BrandHomeContainer}>
    <IndexRoute component={BrandHomePartial} />

    <Route path="campaigns/new" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/CreateCampaignPartial').default);
      }, "createCampaign");
    }}/>

    <Route path="campaigns/:id/edit" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/UpdateCampaignPartial').default);
      }, "updateCampaign");
    }}/>

    <Route path="campaigns/:id" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/ShowCampaignPartial').default);
      }, "showCampaign");
    }}/>

    <Route path="recruits/new" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/CreateRecruitCampaignPartial').default);
      }, "createRecruitCampaign");
    }}/>

    <Route path="recruits/:id" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/ShowRecruitCampaignPartial').default);
      }, "showRecruitCampaign");
    }}/>

    <Route path="recruits/:id/edit" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/UpdateRecruitCampaignPartial').default);
      }, "updateRecruitCampaign");
    }}/>

    <Route path=":id/edit" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/EditProfilePartial').default);
      }, "editProfile");
    }}/>

    <Route path="password" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/UpdatePasswordPartial').default);
      }, "updatePassword");
    }}/>

  <Route path="financial/" getComponent={(nextState, cb) => {
    require.ensure([], (require) => {
      cb(null, require('../containers/FinancialContainer').default);
    }, "recharge");
  }}>

    <IndexRoute getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/FinacialRechargePartial').default);
      }, "FinacialRecharge");
    }}/>

    <Route path="summary" getComponent={(nextState, cb) => {
        require.ensure([], (require) => {
          cb(null, require('../components/FiancialSummaryPartial').default);
        }, "FinacialSummary");
    }}/>

    <Route path="invoice" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/FinacialInvoicePartial').default);
      }, "FinacialInvoice");
    }}/>

  </Route>
</Route>

)
