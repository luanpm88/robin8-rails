console.log("in BrandHomeAppClient");

import React from 'react'
import { Provider } from 'react-redux'
import createStore from '../store/BrandHomeStore'
import BrandHomeContainer from '../containers/BrandHomeContainer'

export default (props) => {
  const store = createStore(props);
  const reactComponent = (
    <Provider store={store}>
      <BrandHomeContainer />
    </Provider>
  );

  return reactComponent;
};
