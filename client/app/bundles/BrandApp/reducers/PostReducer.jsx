import Immutable from 'immutable';
import { actionTypes } from '../constants';

// 每个reducer都有自己的初始结构，最终在index.jsx中拼起来store的初始结构
export const $$initialState = Immutable.fromJS({
  name: '',
});

export default function PostReducer($$state = $$initialState, action) {
  const { type, name } = action;

  switch (type) {
    case actionTypes.POST_NAME_UPDATE:
      return $$state.set('name', name);

    default:
      return $$state;
  }
}
