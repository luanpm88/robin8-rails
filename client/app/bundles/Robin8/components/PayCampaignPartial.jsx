import React from 'react';
import { connect } from 'react-redux';
import { browserHistory } from 'react-router'

import "campaign/pay.scss";

import BreadCrumb from './shared/BreadCrumb';

function select(state) {
  return {
    campaign: state.campaignReducer.get('campaign'),
  }
}

class CreateCampaignPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_pay', '_pay2']);
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;
    fetchCampaign(campaign_id);
  }

  _pay() {
    const { payCampaignByBalance } = this.props.actions;
    const campaign = this.props.campaign;
    payCampaignByBalance(campaign.get("id"));
  }

  _pay2() {
    const { payCampaignByAlipay } = this.props.actions;
    const campaign = this.props.campaign;
    payCampaignByAlipay(campaign.get("id"));
  }

  componentDidMount() {
    this._fetchCampaign();
  }

  componentDidUpdate() {
    if (this.props.campaign.size) {
      if (this.props.campaign.get("status") !== 'unpay') {
        browserHistory.push(`/brand/campaigns/${this.props.campaign.get("id")}/preview`)
      }
    }
  }

  renderSubmitButton() {
    const campaign = this.props.campaign
    if (campaign.get("status") === 'unpay') {
      return (
        <div>
          <button type="submit" onClick={this._pay} className="btn btn-blue btn-lg payCampaignSubmit">立即使用余额支付</button>
          <button type="submit" onClick={this._pay2} className="btn btn-blue btn-lg payCampaignSubmit">立即使用支付宝支付</button>
        </div>
      )
    }
  }

  render() {
    const campaign = this.props.campaign

    return (
      <div className="page page-activity page-activity-pay">
        <div className="container">
         <BreadCrumb />
          <div className="pay-activity-wrap">
            <p>{campaign.get("id")}</p>
            <p>{campaign.get("budget")}</p>
            <p className="help-block">账户余额支付</p>
            <p className="help-block">支付宝支付</p>
            { this.renderSubmitButton() }
          </div>
        </div>
      </div>
    )
  }
}

export default connect(select)(CreateCampaignPartial)
