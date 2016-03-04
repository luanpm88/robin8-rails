import PostReducer from './PostReducer';
import { $$initialState as $$PostInitialState } from './PostReducer';


import CurrentUserReducer from './CurrentUserReducer';
import { $$initialState as $$CurrentUserInitialState } from './CurrentUserReducer';


// 导出所有的reducer
export default {
  $$CurrentUser: CurrentUserReducer,
};

// reducer的初始状态集合
export const initialStates = {
  $$CurrentUserInitialState,
};
