import PostReducer from './PostReducer';
import { $$initialState as $$PostInitialState } from './PostReducer';


// 导出所有的reducer
export default {
  $$PostStore: PostReducer,
};


// reducer的初始状态集合
export const initialStates = {
  $$PostInitialState,
};
