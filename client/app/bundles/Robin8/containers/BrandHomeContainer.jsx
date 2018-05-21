import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import Immutable from 'immutable';
import _ from 'lodash'
import BrandNav from '../components/shared/Nav';

import "base.scss";

import * as brandActionCreators from '../actions/brandActionCreators';


function select(state) {
  return {
    profileData: state.profileReducer
  };
}

class BrandHomeContainer extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    profileData: PropTypes.object.isRequired,
  }

  constructor(props, context) {
    super(props, context);
  }

  render() {
    const { dispatch, profileData } = this.props;
    const actions = bindActionCreators(brandActionCreators, dispatch)

    const childrenWithProps = React.Children.map(this.props.children, (child) =>{
      return React.cloneElement(child, {
        profileData: this.props.profileData,
        actions
      })
    })

    return (
      <div>
        <BrandNav {...{ actions, profileData }} />
        { childrenWithProps }
      </div>
    );
  }
}

export default connect(select)(BrandHomeContainer)
