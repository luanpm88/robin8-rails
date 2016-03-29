import Immutable from 'immutable';
import actionTypes from '../constants/brandConstants';

export const $$initialState = Immutable.fromJS({
  readyState: 'init',
  brand: {},
  campaignList: [],
  paginate: {},
  campaign: {},
  campaign_invites: [],
  hasfetchedInvite: false,
  campaign_statistics: []
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

      return $$state;

    case actionTypes.UPDATE_CAMPAIGN:

      return $$state;

    case actionTypes.FETCH_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
      }
      // console.log($$state.toObject().campaign.toObject())
      return $$state;
    case actionTypes.FETCH_BRAND_PROFILE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "brand": Immutable.fromJS(action.result) });
      }
      return $$state;
    case actionTypes.UPDATE_BRAND_PROFILE:
      return $$state;

    case actionTypes.FETCH_INVITES_OF_CAMPAIGN:
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
      return $$state
    default:
      return $$state;
  }
}
