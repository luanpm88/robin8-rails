import React, { PropTypes } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';

import Campaign from './Campaign';

function select(state) {
  return { CampaignData: state.campaignReducer };
}

class BrandHeader extends React.Component {
  static propTypes = {
    profileData: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  componentDidMount() {
    const { fetchBrandPromotion } = this.props.actions;
    fetchBrandPromotion();
  }

  render() {
    const { actions, profileData } = this.props;
    const brand = profileData.get('brand');
    const promotion_points = brand.get('credit_amount');
    const avail_amount = brand.get("avail_amount");
    const campaignCount = this.props.CampaignData.get("paginate").get('X-Total');

    return (
      <header className="brand-header">
        <div className="container">
          <div className="media brand-info-panel">
            <div className="brand-logo">
              <Link to={`/brand/${brand.get('id')}/edit`}>
                <img src={ !!brand.get('avatar_url') ? brand.get('avatar_url') : require('brand-profile-pic.jpg') } ref="logo" />
              </Link>
            </div>
            <div className="brand-content">
              <Link to={`/brand/${brand.get('id')}/edit`} className="brand-name">{ brand.get('name') }</Link>
            </div>

            <div className="brand-info-status row">
              <div className="col-sm-4 item">我的推广活动：<strong>{campaignCount}</strong></div>
              <div className="col-sm-4 item">当前余额：￥<strong>{avail_amount}</strong><Link to="/brand/financial/recharge" className="btn btn-blue btn-default btn-sm recharge-btn">充值</Link></div>
              <div className="col-sm-4 item">当前剩余积分：<strong>{promotion_points}</strong></div>
            </div>
          </div>
          {/*<div className="brand-logo">
            <Link to={`/brand/${brand.get('id')}/edit`}>
              <img src={ !!brand.get('avatar_url') ? brand.get('avatar_url') : require('brand-profile-pic.jpg') } ref="logo" />
            </Link>
          </div>
          <div className="brand-content">
            <Link to={`/brand/${brand.get('id')}/edit`} className="brand-name">{ brand.get('name') }</Link>
          </div>*/}
        </div>
      </header>
    );
  }
}

export default connect(select)(BrandHeader)
