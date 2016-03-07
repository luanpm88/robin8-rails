console.log("in BrandHomeContainer");

import React, { PropTypes } from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import Immutable from 'immutable'
import BrandNav from '../components/BrandNav'
import BrandHeader from '../components/BrandHeader'
import CampaignList from '../components/CampaignList'
import "base.css";
import "home.css";

import * as brandHomeActionCreators from '../actions/brandHomeActionCreators'


function select(state) {
  return { data: state.$$brandHomeStore };
}

class BrandHomeContainer extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    data: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  render() {
    const { dispatch, data } = this.props;
    const actions = bindActionCreators(brandHomeActionCreators, dispatch)

    return (
      <div>
        <BrandNav {...{ actions, data }} />
        <BrandHeader {...{ actions, data }} />
        <CampaignList {...{ actions, data }} />
      </div>
    );
  }
}

export default connect(select)(BrandHomeContainer)
