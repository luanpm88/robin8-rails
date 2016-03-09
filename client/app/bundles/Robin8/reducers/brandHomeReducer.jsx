import Immutable from 'immutable'
import actionTypes from '../constants/BrandHomeConstants'

export const $$initialState = Immutable.fromJS({
  readyState: 'init',
  campaignList: [],
  currentPage: "",
  totalPages: "",
  campaignsCount: ""
});

export default function brandHomeReducer($$state = $$initialState, action = null) {
  const { type, campaignList } = action;
  switch (type) {
    case actionTypes.FETCH_CAMPAIGNS:
      const fetchState = action.readyState;
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "campaignList": Immutable.fromJS(action.result.campaigns),
          "currentPage": Immutable.fromJS(action.result.current_page),
          "totalPages": Immutable.fromJS(action.result.total_page),
          "campaignsCount": Immutable.fromJS(action.result.campaigns_count)
        });
      }
      return $$state;
    default:
      return $$state;
  }
}
