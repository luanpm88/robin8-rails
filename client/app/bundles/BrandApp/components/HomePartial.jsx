import React from 'react';
/*import InfluencePartial from './home/InfluencePartial';*/
/*import MediaPartial from './home/MediaPartial';*/
import CampaignPartial from './home/CampaignPartial';

import "home.css";

export default class HomePartial extends React.Component {
  componentDidMount() {
    this.props.campaignActions.requestCampaigns();
  }

  render() {
    return (
      <div>
        <header className="brand-header">
          <div className="container-fluid">
            <div className="brand-logo"><img src={ require("temp/brand_logo.png") } /></div>
            <div className="brand-menu">
              <div className="dropdown">
                <a href="#" className="brand-name" data-toggle="dropdown">{this.props.$$CurrentUser.get('name')}<i className="caret-arrow" /></a>
                <ul className="dropdown-menu">
                  <li><a href="#">Action</a></li>
                </ul>
              </div>
            </div>
          </div>
        </header>
        <div className="wrapper">
          <div className="container">
            {/*<InfluencePartial />*/}
            {/*<MediaPartial />*/}
            <CampaignPartial $$Campaign={this.props.$$Campaign} />
          </div>
        </div>
      </div>
    );
  }
}