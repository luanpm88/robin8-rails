import React from 'react';
import { Provider } from 'react-redux';
import createStore from '../store/BrandStore';
import BrandApp from '../containers/BrandApp';

// 这里的props是 Rails helper react_component 传进来的 props
export default (props) => {
  const store = createStore(props);

  console.log(store.getState());
  let unsubscribe = store.subscribe(() =>
    console.log(store.getState())
  );

  return <Provider store={store}>
    <BrandApp />
  </Provider>;
};
