import CurrentUserReducer from './CurrentUserReducer';
import { $$initialState as $$CurrentUserInitialState } from './CurrentUserReducer';

import CampaignReducer from './CampaignReducer';
import { $$initialState as $$CampaignInitialState } from './CampaignReducer';


// 导出所有的reducer
export default {
  $$CurrentUser: CurrentUserReducer,
  $$Campaign: CampaignReducer
};

// reducer的初始状态集合
export const initialStates = {
  $$CurrentUserInitialState,
  $$CampaignInitialState
};
