import React, { PropTypes } from 'react';
import CampaignList from './brand_home/CampaignList';
import Header from './brand_home/Header'

import "home.scss";

export default class BrandHeader extends React.Component {

  constructor(props, context) {
    super(props, context);
  }

  render() {

    const { actions, data } = this.props;
    const brand = data.get('brand');

    return (
      <div className="page page-home">
        <Header {...this.props} />
        <CampaignList {...this.props} />
      </div>
    );
  }
}
