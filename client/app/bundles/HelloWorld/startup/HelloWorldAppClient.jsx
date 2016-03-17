import React from 'react';
import { Provider } from 'react-redux';

import createStore from '../store/helloWorldStore';
import HelloWorld from '../containers/HelloWorld';

// See documentation for https://github.com/reactjs/react-redux.
// This is how you get props from the Rails view into the redux store.
// This code here binds your smart component to the redux store.
export default (props) => {
  // store 介绍： http://cn.redux.js.org/docs/basics/Store.html
  const store = createStore(props);

  // 监听 state 更新时，打印日志
  // 注意 subscribe() 返回一个函数用来注销监听器
  console.log(store.getState());
  let unsubscribe = store.subscribe(() =>
    console.log(store.getState())
  );
  // 取消监听使用 unsubscribe(); 便于调试时 追踪变化 流程。

  const reactComponent = (
    // 追踪一下provider 的原理
    // 如何 将 HelloWorld 需要的参数 传进来的
    // andy 的理解 是 store 会作为 props 一个参数 参进去。
    <Provider store={store}>
      <HelloWorld />
    </Provider>
  );
  return reactComponent;
};
