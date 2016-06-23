import React from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import { browserHistory } from 'react-router'

import "campaign/pay.scss";

import BreadCrumb from './shared/BreadCrumb';

function select(state) {
  return {
    brand: state.profileReducer.get("brand"),
    campaign: state.campaignReducer.get('campaign')
  }
}

class PayCampaignPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_pay']);
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;
    fetchCampaign(campaign_id);
  }

  _pay() {
    const { payCampaignByBalance, payCampaignByAlipay } = this.props.actions;
    const campaign = this.props.campaign;
    if ($('.check-alipay').attr('value') === 'alipay' && $('.check-balance').attr('value') === "") {
      payCampaignByAlipay(campaign.get("id"));
    }
    if ($('.check-alipay').attr('value') === '' && $('.check-balance').attr('value') === "balance") {
      payCampaignByBalance(campaign.get("id"));
    }
  }

  choosePayWay() {
    $('.check-balance').addClass("checked-img");
    $('.check-balance').attr("value", "balance")
    $('.check-alipay').attr("value", "")
    $('.check-balance').on('click', function(){
      $(this).attr("value", "balance")
      $(this).addClass("checked-img");
      $('.check-alipay').removeClass("checked-img")
      $('.check-alipay').attr("value", "")
    })
    $('.check-alipay').on('click', function(){
      $(this).attr("value", "alipay")
      $(this).addClass("checked-img");
      $('.check-balance').removeClass("checked-img")
      $('.check-balance').attr("value", "")
    })
  }

  componentDidMount() {
    this._fetchCampaign();
    this.choosePayWay();
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
        <div className="payCampaignSubmit">
          <button type="submit" onClick={this._pay} className="btn btn-blue btn-lg">立即支付</button>
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
            <p className="pay-type">请选择支付方式</p>
            <hr />
            <div className="pay-by-balance">
              <span className="pay-by-balance-text">账户余额支付</span>
              <span className="balance-amount">&nbsp;&nbsp;(余额 ￥ {this.props.brand.get("avail_amount")})</span>
              <Link to="/brand/financial/recharge" className="recharge" target="_blank">&nbsp;&nbsp;立即充值</Link>

              <div ref='check-balance' className="check-balance">

              </div>

            </div>
            <hr />
            <div className="pay-by-alipay">
              <span className="pay-by-alipay-text">支付宝支付</span>
              <span className="alipay-pay-tip">&nbsp;&nbsp;(支付宝支付暂不支持开具发票)</span>
              <div ref='check-alipay' className="check-alipay">

              </div>
            </div>
            <hr />
            <div className="total-pay-amount">
              <span className="pay-amount-text">支付总额: </span>
              <span className="pay-amount-text">￥</span>
              <span className="need-pay-amount">{campaign.get("need_pay_amount")}</span>
            </div>
          </div>
          { this.renderSubmitButton() }
        </div>
      </div>
    )
  }
}

export default connect(select)(PayCampaignPartial)
