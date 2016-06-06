import { compose, createStore, applyMiddleware, combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux'
import thunkMiddleware from 'redux-thunk'
import { reducer as formReducer } from 'redux-form'
import loggerMiddleware from 'lib/middlewares/loggerMiddleware'
import promiseMiddleware from 'lib/middlewares/promiseMiddleware'

import campaignReducer from '../reducers/campaignReducer';
import financialReducer from '../reducers/financialReducer';
import profileReducer from '../reducers/profileReducer';

export default props => {

  const { brand } = props;

  const reducer = combineReducers({
    campaignReducer,
    financialReducer,
    profileReducer,
    routing: routerReducer,
    form: formReducer
  })

  const composeStore = compose(
    applyMiddleware(thunkMiddleware, promiseMiddleware, loggerMiddleware)
  );

  const storeCreator = composeStore(createStore);

  const store = storeCreator(reducer);

  return store;

}
