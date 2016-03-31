import React, { PropTypes } from 'react';
import CampaignList from './brand_home/CampaignList';
import Header from './brand_home/Header'

export default class BrandHeader extends React.Component {

  constructor(props, context) {
    super(props, context);
  }

  render() {

    const { actions, data } = this.props;
    const brand = data.get('brand');

    return (
      <div>
        <Header {...this.props} />
        <CampaignList {...this.props} />
      </div>
    );
  }
}
