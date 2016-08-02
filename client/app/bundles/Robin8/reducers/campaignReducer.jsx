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
  campaign_installs: [],
  selected_kols: [],
  searched_kols: {
    items: [],
    paginate: {}
  },
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

    case actionTypes.GO_PAY_CAMPAIGN:
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

    case actionTypes.REVOKE_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
      }
      return $$state;

    case actionTypes.PAY_CAMPAIGN_BY_ALIPAY:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        if(action.result.alipay_recharge_url) {
          window.location = action.result.alipay_recharge_url;
        }
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
    case actionTypes.FETCH_INSTALLS_OF_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success"){
        $$state = $$state.merge({
          "campaign_installs": Immutable.fromJS(action.result.items),
        })
      }
      return $$state;
    case actionTypes.SEARCH_KOLS_IN_CONDITION:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success"){
        if (action.result.items.length > 0) {
          $$state = $$state.mergeIn(['searched_kols', 'items'], action.result.items);
        } else {
          $$state = $$state.setIn(['searched_kols', 'items'], Immutable.List());
        }
        $$state = $$state.mergeIn(['searched_kols', 'paginate'], action.result.paginate);
      }
      return $$state;
    case actionTypes.ADD_SELECTED_KOL:
      if (!$$state.get("selected_kols").find((k) => {
        return k.get("id") == action.data.get("id")
      })) {
        $$state = $$state.merge({
          "selected_kols": $$state.get("selected_kols").push(action.data)
        })
      }
      return $$state;
    case actionTypes.REMOVE_SELECTED_KOL:
      const selectedKolIndex = $$state.get("selected_kols").findIndex((k) => {
        return k.get("id") == action.data.get("id")
      })

      if (selectedKolIndex >= 0) {
        $$state = $$state.merge({
          "selected_kols": $$state.get("selected_kols").delete(selectedKolIndex)
        })
      }
      return $$state;
    default:
      return $$state;
  }
}
