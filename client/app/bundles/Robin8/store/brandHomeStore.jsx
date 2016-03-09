import { compose, createStore, applyMiddleware, combineReducers } from 'redux'
import thunkMiddleware from 'redux-thunk'
import loggerMiddleware from 'lib/middlewares/loggerMiddleware'
import promiseMiddleware from 'lib/middlewares/promiseMiddleware'
import reducers from '../reducers'
import { initialStates } from '../reducers'


export default props => {

  const { brand } = props;
  const { $$brandHomeState } = initialStates;
  const initialState = {
    $$brandHomeStore: $$brandHomeState.merge({
      brand,
    }),
  };

  const reducer = combineReducers(reducers)

  const composeStore = compose(
    applyMiddleware(thunkMiddleware, promiseMiddleware, loggerMiddleware)
  );

  const storeCreator = composeStore(createStore);

  const store = storeCreator(reducer, initialState);

  return store;

}
