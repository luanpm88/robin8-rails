import React from 'react';
import { Route, IndexRoute } from 'react-router';
import BrandHomeContainer from '../containers/BrandHomeContainer';
import BrandHomePartial from '../components/BrandHomePartial';
export default (
  <Route path="/brand" component={BrandHomeContainer}>
    <IndexRoute component={BrandHomePartial} />

    <Route path="campaigns/select" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/SelectCampaignPartial').default);
      }, "selectCampaign");
    }}/>

    <Route path="campaigns/analysis" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/AnalysisCampaignPartial').default);
      }, "analysisCampaign");
    }}/>

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

    <Route path="campaigns/:id/evaluate" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/EvaluateCampaignPartial').default);
      }, "evaluateCampaign");
    }}/>

    <Route path="campaigns/:id/edit_base" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/UpdateCampaignBasePartial').default);
      }, "updateCampaignBase");
    }}/>

    <Route path="campaigns/:id/preview" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/PreviewCampaignPartial').default);
      }, "previewCampaign");
    }}/>

    <Route path="campaigns/:id/pay" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/PayCampaignPartial').default);
      }, "payCampaign");
    }}/>

    <Route path="campaigns/:id/analysis_invite" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/AnalysisCampaignInvitePartial').default);
      }, "analysisCampaignInvite");
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

    <Route path="invites/new" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/CreateInviteCampaignPartial').default);
      }, "createInviteCampaign");
    }}/>

    <Route path="invites/:id" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/ShowInviteCampaignPartial').default);
      }, "showInviteCampaign");
    }}/>

    <Route path="invites/:id/edit" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/UpdateInviteCampaignPartial').default);
      }, "updateInviteCampaign");
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

  <Route path="financial/recharge" getComponent={(nextState, cb) => {
    require.ensure([], (require) => {
      cb(null, require('../components/FinancialRechargePartial').default);
    }, "FinancialRecharge");
  }} />


  <Route path="financial/summary" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/FinancialSummaryPartial').default);
      }, "FinancialSummary");
  }}/>

  <Route path="financial/summary/integral" getComponent={(nextState, cb) => {
      require.ensure([], (require) => {
        cb(null, require('../components/FinancialSummaryIntegralPartial').default);
      }, "FinancialSummaryIntegral");
  }}/>

  <Route path="financial/invoice" getComponent={(nextState, cb) => {
    require.ensure([], (require) => {
      cb(null, require('../components/FinancialInvoicePartial').default);
    }, "FinancialInvoice");
  }}/>
</Route>

)
