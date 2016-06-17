import Immutable from 'immutable';
import actionTypes from '../constants/brandConstants';
import _ from 'lodash';

export const initialState = Immutable.fromJS({
  readyState: 'init',
  campaignList: [],
  campaign: {},
  campaign_invites: [],
  hasfetchedInvite: false,
  campaign_statistics: [],
  paginate: {},
  error: ""
});

export default function campaignReducer($$state = initialState, action=nil) {
  const { type } = action;
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

    case actionTypes.PAY_CAMPAIGN_BY_BALANCE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
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
    default:
      return $$state;
  }
}
