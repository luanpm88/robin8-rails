console.log("in BrandHeader");

import React, { PropTypes } from 'react'
import CampaignList from './brand_home/CampaignList'

export default class BrandHeader extends React.Component {

  constructor(props, context) {
    super(props, context);
  }

  render() {

    const { actions, data } = this.props;
    const brand = data.get('brand');

    return (
      <div>
        <header className="brand-header">
          <div className="container-fluid">
            <div className="brand-logo"><img src={ brand.get('avatar_url') } /></div>
            <div className="brand-menu">
              <div className="dropdown">
                <a href="#" className="brand-name" data-toggle="dropdown">{ brand.get('email') }<i className="caret-arrow"></i></a>
                <ul className="dropdown-menu">
                  <li><a href="#">Action</a></li>
                </ul>
              </div>
            </div>
          </div>
        </header>
        <CampaignList {...this.props} />
      </div>
    );
  }
}
