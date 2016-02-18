import React, { PropTypes } from 'react';
import HelloWorldWidget from '../components/HelloWorldWidget';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import Immutable from 'immutable';
import * as helloWorldActionCreators from '../actions/helloWorldActionCreators';

function select(state) {
  // Which part of the Redux global state does our component want to receive as props?
  // Note the use of `$$` to prefix the property name because the value is of type Immutable.js
  // 使用 $$ 定义 表示 这个 这个值是 Immutable(不可改变的)。
  // 表示 我们的 component 希望 将redux  global state 作为一个参数 传进来。

  return { $$helloWorldStore: state.$$helloWorldStore };
}

// Simple example of a React "smart" component
class HelloWorld extends React.Component {
  // 表示传入的参数 有哪些, 什么格式, 是否必须等等。

  static propTypes = {
    dispatch: PropTypes.func.isRequired,

    // This corresponds to the value used in function select above.
    // We prefix all property and variable names pointing to Immutable.js objects with '$$'.
    // This allows us to immediately know we don't call $$helloWorldStore['someProperty'], but
    // instead use the Immutable.js `get` API for Immutable.Map
    $$helloWorldStore: PropTypes.instanceOf(Immutable.Map).isRequired,
  };

  constructor(props, context) {
    super(props, context);
  }

  render() {
    // 下面的一行的写法 等价于 
    // const dispatch = this.props.dispatch
    // const $$helloWorldStore = this.props.helloWorldStore
    const { dispatch, $$helloWorldStore } = this.props;

    // bindActionCreators() 可以自动把多个 action 创建函数 绑定到 dispatch()方法上。
    const actions = bindActionCreators(helloWorldActionCreators, dispatch);
    const { updateName } = actions;

    // 获取从 服务器那边传过来的值, 同时 如果在输入框 改变了值, 会触发 updateName, 又会渲染这个Component, 就又会走下面的流程。
    const name = $$helloWorldStore.get('name');

    // This uses the ES2015 spread operator to pass properties as it is more DRY
    // This is equivalent to:
    // <HelloWorldWidget $$helloWorldStore={$$helloWorldStore} actions={actions} />
    console.log("-----------xxxx");

    // 思考 ...{ updateName, name } 的目的 
    //  这个是es6 的写法: http://es6.ruanyifeng.com/
    //  … {updateName, name }的 作用  是他们变成一个hash 
    // {"name": 对应的值, "updateName": 对应的值}
    return (
      <HelloWorldWidget {...{ updateName, name }} />
    );
  }
}

// Don't forget to actually use connect!
// Note that we don't export HelloWorld, but the redux "connected" version of it.
// See https://github.com/reactjs/react-redux/blob/master/docs/api.md#examples
// 思考 这里的 connect 的原理 和用法
// 需要 显示的绑定一下 HelloWorld
export default connect(select)(HelloWorld);
