import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import Immutable from 'immutable';
import _ from 'lodash'
import BrandNav from '../components/shared/Nav';
import "base.css";
import "home.css";

import * as brandActionCreators from '../actions/brandActionCreators';


function select(state) {
  return { data: state.$$brandStore };
}

class BrandHomeContainer extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    data: PropTypes.object.isRequired,
  }

  constructor(props, context) {
    super(props, context);
  }

  render() {
    const { dispatch, data } = this.props;
    const actions = bindActionCreators(brandActionCreators, dispatch)

    const childrenWithProps = React.Children.map(this.props.children, (child) =>{
      return React.cloneElement(child, {
        data: this.props.data,
        actions
      })
    })


    return (
      <div>
        <BrandNav {...{ actions, data }} />
        { childrenWithProps }
      </div>
    );
  }
}

export default connect(select)(BrandHomeContainer)
