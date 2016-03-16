import Immutable from 'immutable'
import actionTypes from '../constants/BrandHomeConstants'

export const $$initialState = Immutable.fromJS({
  readyState: 'init',
  campaignList: [],
  paginate: {}
});

export default function brandHomeReducer($$state = $$initialState, action = null) {
  const { type, campaignList } = action;
  switch (type) {
    case actionTypes.FETCH_CAMPAIGNS:
      const fetchState = action.readyState;
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

    default:
      return $$state;
  }
}
