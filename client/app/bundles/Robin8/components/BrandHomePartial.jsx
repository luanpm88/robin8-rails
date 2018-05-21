import React, { PropTypes } from 'react';
import CampaignList from './brand_home/CampaignList';
import Header from './brand_home/Header'

import "home.scss";

export default class BrandHeader extends React.Component {

  constructor(props, context) {
    super(props, context);
  }

  render() {
    console.log(this.props);
    const { actions, profileData } = this.props;
    const brand = profileData.get('brand');

    return (
      <div className="page page-home">
        <Header {...this.props} />
        <CampaignList {...this.props} />
      </div>
    );
  }
}
