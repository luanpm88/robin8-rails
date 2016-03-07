import Immutable from 'immutable'
import actionTypes from '../constants/brandHomeConstants'

export const $$initialState = Immutable.fromJS({
  brand: "",
  campaignList: [],
  isFetching: false,
  fetchBrandEmailError: null
});

export default function brandHomeReducer($$state = $$initialState, action = null) {
  const { type, email, campaignList, error } = action;
  switch (type) {
    case actionTypes.SET_IS_FETCHING:
      return $$state.merge({
        isFetching: true
      })

    case actionTypes.FETCH_CAMPAIGN_LIST_SUCCESS:
      return $$state.merge({
        campaignList: campaignList,
        isFetching: false
      })

    case actionTypes.FETCH_CAMPAIGN_LIST_FAILURE:
      return $$state.merge({
        fetchCampignListError: error,
        isFetching: false
      })

    default:
      return $$state;
  }
}
