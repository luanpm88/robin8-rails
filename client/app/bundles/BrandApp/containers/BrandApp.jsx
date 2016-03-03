import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import Immutable from 'immutable';
import * as PostActionCreators from '../actions/PostActionCreators';
import NavPartial from '../components/NavPartial';

import "base.css";

const mapStateToProps = (state) => ({
  $$PostStore: state.$$PostStore
});

class Layout extends React.Component {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    $$PostStore: PropTypes.instanceOf(Immutable.Map).isRequired,
    children: PropTypes.object.isRequired,
  };

  constructor(props, context) {
    super(props, context);
  }

  render() {
    return (
      <div>
        <NavPartial />
        {this.props.children}
      </div>
    );
  }
}

// 将一个Component变成Smart的
// 调用原理原理类似python 的 Decorator，如果使用babel，可以用Decorator语法
// https://github.com/reactjs/react-redux/blob/master/docs/api.md#connectmapstatetoprops-mapdispatchtoprops-mergeprops-options
export default connect(mapStateToProps)(Layout);
