import Immutable from 'immutable';
import { actionTypes } from '../constants';

export const $$initialState = Immutable.fromJS({
  readyState: 'init',
  items: []
});

export default function CampaignReducer($$state = $$initialState, action) {
  const { type, name } = action;

  switch (type) {
    case actionTypes.REQUEST_CAMPAIGNS:
      const requestState = action.readyState;
      $$state = $$state.set("readyState", requestState);

      if(requestState === 'success') {
        $$state = $$state.set("items", Immutable.fromJS(action.result.campaigns));
      }

      return $$state;
    case actionTypes.SAVE_CAMPAIGN:

      // cache for items
      return $$state;
    default:
      return $$state;
  }
}
