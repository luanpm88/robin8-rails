import Immutable from 'immutable';
import actionTypes from '../constants/brandConstants';

export const $$initialState = Immutable.fromJS({
  readyState: 'init',
  campaignList: [],
  paginate: {},
  campaign: {}
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

    default:
      return $$state;
  }
}
