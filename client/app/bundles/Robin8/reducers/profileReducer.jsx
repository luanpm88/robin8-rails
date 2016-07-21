import Immutable from 'immutable';
import actionTypes from '../constants/brandConstants';
import _ from 'lodash';

export const initialState = Immutable.fromJS({
  readyState: 'init',
  brand: {},
  error: ""
});

export default function profileReducer($$state = initialState, action=nil) {
  const { type } = action;
  const fetchState = action.readyState;
  switch (type) {
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
        window.location = '/logout';
      }
      return $$state;
    default:
      return $$state;
  }
}
