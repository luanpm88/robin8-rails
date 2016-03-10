import { compose, createStore, applyMiddleware, combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux'
import thunkMiddleware from 'redux-thunk'
import { reducer as formReducer } from 'redux-form'
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

  const reducer = combineReducers({
    ...reducers,
    routing: routerReducer,
    form: formReducer
  })

  const composeStore = compose(
    applyMiddleware(thunkMiddleware, promiseMiddleware, loggerMiddleware)
  );

  const storeCreator = composeStore(createStore);

  const store = storeCreator(reducer, initialState);

  return store;

}
