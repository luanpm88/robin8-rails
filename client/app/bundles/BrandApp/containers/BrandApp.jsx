import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import Immutable from 'immutable';
import * as PostActionCreators from '../actions/PostActionCreators';
import UpdatePostPartial from '../components/UpdatePostPartial';

const mapStateToProps = (state) => ({
  $$PostStore: state.$$PostStore
});

class Layout extends React.Component {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    $$PostStore: PropTypes.instanceOf(Immutable.Map).isRequired,
  };

  constructor(props, context) {
    super(props, context);
  }

  render() {
    // 因为connect，这个Component是smart的，拥有dispatch和mapStateToProps注册进来的属性
    const { dispatch, $$PostStore } = this.props;

    // bind的作用是，生成绑定好的函数（可以直接调用，不需要dispatch，为的是让非smart Component方便调用）
    const actions = bindActionCreators(PostActionCreators, dispatch);
    const { updateName } = actions;

    const name = $$PostStore.get('name');

    return (
      <UpdatePostPartial {...{ updateName, name }} />
    );
  }
}

// 将一个Component变成Smart的
// 调用原理原理类似python 的 Decorator，如果使用babel，可以用Decorator语法
// https://github.com/reactjs/react-redux/blob/master/docs/api.md#connectmapstatetoprops-mapdispatchtoprops-mergeprops-options
export default connect(mapStateToProps)(Layout);
