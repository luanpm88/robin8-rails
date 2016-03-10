console.log("in BrandHomeContainer");

import React, { PropTypes } from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import Immutable from 'immutable'
import BrandNav from '../components/brand_home/Nav'
import BrandHeader from '../components/brand_home/Header'
import "base.css";
import "home.css";

import * as brandHomeActionCreators from '../actions/BrandHomeActionCreators'


function select(state) {
  return { data: state.$$brandHomeStore };
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
    const actions = bindActionCreators(brandHomeActionCreators, dispatch)

    const childrenWithProps = React.Children.map(this.props.children, (child) =>{
      return React.cloneElement(child, {
        data: this.props.data,
        actions
      })
    })


    return (
      <div>
        <BrandNav {...{ actions, data }} />
        <BrandHeader {...{ actions, data }} />
        { childrenWithProps }
      </div>
    );
  }
}

export default connect(select)(BrandHomeContainer)
