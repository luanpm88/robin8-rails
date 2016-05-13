import Immutable from 'immutable';
import actionTypes from '../constants/brandConstants';
import _ from 'lodash';

export const $$initialState = Immutable.fromJS({
  readyState: 'init',
  brand: {},
  campaignList: [],
  paginate: {},
  campaign: {},
  campaign_invites: [],
  hasfetchedInvite: false,
  campaign_statistics: [],
  transactions: [],
  error: ""
});

export default function brandReducer($$state = $$initialState, action = null) {
  const { type, campaignList } = action;
  const fetchState = action.readyState;
  switch (type) {
    case actionTypes.FETCH_CAMPAIGNS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "campaignList": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate)
        });
      }
      return $$state;

    case actionTypes.SAVE_CAMPAIGN:
      if(fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState });
      }

      return $$state;
    case actionTypes.UPDATE_RECRUIT:
    case actionTypes.UPDATE_CAMPAIGN:
      if(fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      console.log("fetchState" + fetchState);
      return $$state;

    case actionTypes.FETCH_RECRUIT:
    case actionTypes.FETCH_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
      }
      // console.log($$state.toObject().campaign.toObject())
      return $$state;

    case actionTypes.UPDATE_RECRUIT_CAMPAIGN_KOL_STATUS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.mergeIn(['campaign', 'brand_passed_count'], action.result.brand_passed_count);
        $$state = $$state.mergeIn(['campaign_invites', action.index, 'status'], action.result.status);
      }
      return $$state;

    case actionTypes.UPDATE_RECRUIT_CAMPAIGN_KOLS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
      }
      return $$state;

    case actionTypes.FETCH_RECRUIT_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
      }
      return $$state;

    case actionTypes.FETCH_BRAND_PROFILE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "brand": Immutable.fromJS(action.result) });
      }
      return $$state;

    case actionTypes.UPDATE_BRAND_PROFILE:
      return $$state;

    case actionTypes.UPDATE_BRAND_PASSWORD:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      if(fetchState === 'success') {
        window.location = '/users/sign_out';
        window.location = '/';
      }
      return $$state;

    case actionTypes.FETCH_INVITES_OF_CAMPAIGN:
    case actionTypes.FETCH_APPLIES_OF_RECRUIT_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success"){
        $$state = $$state.merge({
          "campaign_invites": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate),
          "hasfetchedInvite": true
        });
      }
      return $$state;

    case actionTypes.FETCH_STATISTICS_CLICKS_OF_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success"){
        $$state = $$state.merge({
          "campaign_statistics": Immutable.fromJS(action.result.items),
        })
      }
      return $$state;

    case actionTypes.ALIPAY_RECHARGE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success") {
        if(action.result.alipay_recharge_url) {
          window.location = action.result.alipay_recharge_url;
        }
      } else if (fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
    case actionTypes.FETCH_TRANSACTIONS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "transactions": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate)
        });
      }
      return $$state;

    default:
      return $$state;
  }
}
