import { compose, createStore, applyMiddleware, combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';
// 异步 action_creator
// 文档 http://camsong.github.io/redux-in-chinese/docs/advanced/AsyncActions.html
import thunkMiddleware from 'redux-thunk';

// loggerMiddleware
// redux中的middleware它提供的是位于 action 被发起之后，到达 reducer 之前的扩展点
// 文档 http://camsong.github.io/redux-in-chinese/docs/advanced/Middleware.html
import loggerMiddleware from 'lib/middlewares/loggerMiddleware';

import reducers from '../reducers';
import { initialStates } from '../reducers';

export default props => {
  // props参数是 Rails helper react_component 传进来的 props

  const { name } = props;

  // 根据rails传进来的参数 与 reducers里边定义的初始状态集合，构建最终store的初始状态
  const { $$PostInitialState } = initialStates;
  const initialState = {
    $$PostStore: $$PostInitialState.merge({
      name,
    }),
  };

  // 这些都是redux的一些基本的创建store、添加middleware的函数
  const reducer = combineReducers({
    ...reducers,
    routing: routerReducer,
  });

  const composedStore = compose(
    applyMiddleware(thunkMiddleware, loggerMiddleware)
  );

  const storeCreator = composedStore(createStore);
  const store = storeCreator(reducer, initialState);

  return store;
};
