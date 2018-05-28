import React from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import { browserHistory } from 'react-router'

import "campaign/pay.scss";

import BreadCrumb from './shared/BreadCrumb';

function select(state) {
  return {
    brand: state.profileReducer.get("brand"),
    promotion: state.profileReducer.get('promotion'),
    campaign: state.campaignReducer.get('campaign')
  }
}

class PayCampaignPartial extends React.Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      userDeduction: true
    };
    _.bindAll(this, ['_fetchCampaign', '_pay', '_deductionCheck']);
  }

  _deductionCheck() {
    this.setState({
      userDeduction: !this.state.userDeduction
    });

    console.log(this.state.userDeduction);
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
      payCampaignByAlipay(campaign.get("id"), this.state.userDeduction);
    }
    if ($('.check-alipay').attr('value') === '' && $('.check-balance').attr('value') === "balance") {
      payCampaignByBalance(campaign.get("id"), this.state.userDeduction);
    }
  }

  choosePayWay() {
    $('.check-balance .ok-sign').addClass("checked-img");
    $('.check-balance').attr("value", "balance")
    $('.check-alipay').attr("value", "")
    $('.check-balance').on('click', function(){
      $('.check-balance').attr("value", "balance")
      $('.check-balance .ok-sign').addClass("checked-img");
      $('.check-alipay .ok-sign').removeClass("checked-img")
      $('.check-alipay').attr("value", "")
    })
    $('.check-alipay').on('click', function(){
      $('.check-alipay').attr("value", "alipay")
      $('.check-alipay .ok-sign').addClass("checked-img");
      $('.check-balance .ok-sign').removeClass("checked-img")
      $('.check-balance').attr("value", "")
    })
  }

  componentDidMount() {
    const { fetchBrandPromotion } = this.props.actions;
    fetchBrandPromotion();

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
    const campaign = this.props.campaign;
    const need_pay_amount = campaign.get("need_pay_amount");
    const brand = this.props.brand;
    const promotion_points = brand.get('credit_amount');
    const promotion = this.props.promotion;
    // const promotion_rate = promotion.get('rate');
    const promotion_rate = 0.1;
    const deduction_price = Math.floor(promotion_points * promotion_rate) > need_pay_amount ? need_pay_amount : Math.floor(promotion_points * promotion_rate);

    console.log('brand', brand);
    console.log('promotion', promotion);

    return (
      <div className="page page-activity page-activity-pay">
        <div className="container">
          <BreadCrumb />
          <div className="pay-activity-wrap">
            <p className="pay-type">请选择支付方式</p>
            <hr />
            <div className="pay-by-balance">
              <span className="pay-by-balance-text">账户积分支付</span>
              <span className="balance-amount">&nbsp;&nbsp;(剩余积分 {promotion_points}，可抵扣 {deduction_price} 元)</span>
              <div ref='check-credit' className="check-credit" onClick={this._deductionCheck}>
                <span className={this.state.userDeduction ? 'ok-sign checked-img' : 'ok-sign'}></span>
              </div>
            </div>
            <hr />
            <div className="pay-by-balance">
              <span className="pay-by-balance-text">账户余额支付</span>
              <span className="balance-amount">&nbsp;&nbsp;(余额 ￥ {brand.get("avail_amount")})</span>
              <Link to="/brand/financial/recharge" className="recharge" target="_blank">&nbsp;&nbsp;立即充值</Link>

              <div ref='check-balance' className="check-balance">
                <span className="ok-sign"></span>
              </div>
            </div>
            <hr />
            <div className="pay-by-alipay">
              <span className="pay-by-alipay-text">支付宝支付</span>
              <span className="alipay-pay-tip">&nbsp;&nbsp;(支付宝支付暂不支持开具发票)</span>
              <div ref='check-alipay' className="check-alipay">
                <span className="ok-sign"></span>
              </div>
            </div>
            <hr />
            <div className="total-pay-status">
              <span>支付总额：￥{need_pay_amount}</span>
              <span>积分抵扣：￥{this.state.userDeduction ? deduction_price : 0}</span>
            </div>
            <div className="total-pay-amount">
              <span className="pay-amount-text">实际支付：</span>
              <span className="pay-amount-text">￥</span>
              <span className="need-pay-amount">{need_pay_amount - (this.state.userDeduction ? deduction_price : 0)}</span>
            </div>
          </div>
          { this.renderSubmitButton() }
        </div>
      </div>
    )
  }
}

export default connect(select)(PayCampaignPartial)
