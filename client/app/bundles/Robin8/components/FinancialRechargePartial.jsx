import React from 'react';
import { Link } from 'react-router';
import validator from 'validator';

import BreadCrumb from './shared/BreadCrumb';
import FinancialMenu from './shared/FinancialMenu';
import RechargeModal from './financial/modals/RechargeModal';

import 'recharge/recharge.scss';

class FinancialRechargePartial extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      showRechargeModal: false,
      credits: "",
      inviteCode: "",
      creditPoints: ""
    };
  }

  closeRechargeModal() {
    this.setState({showRechargeModal: false});
  }

  //choose_price(e) {
  //  this.refs.priceInput.value = "";
  //  this.refs.price_500.style.border = '1px solid #dce4e6';
  //  this.refs.price_1000.style.border = '1px solid #dce4e6';
  //  this.refs.price_2000.style.border = '1px solid #dce4e6';
  //  $('button i').hide();
  //  $(".error-tips p").hide();
  //  if(e.target.value === '500') {
  //    this.refs.price_500.style.borderColor = "rgb(40, 182, 187)";
  //    this.refs.price_500.children[0].style.display = "block"
  //  } else if (e.target.value === '1000') {
  //    this.refs.price_1000.style.borderColor = "rgb(40, 182, 187)";
  //    this.refs.price_1000.children[0].style.display = "block"
  //  } else if (e.target.value === '2000'){
  //    this.refs.price_2000.style.borderColor = "rgb(40, 182, 187)";
  //    this.refs.price_2000.children[0].style.display = "block"
  //  }
  //}

  check_price() {
    // 判断金额是否符合要求: 金额必须存在 金额为整数  大于500元
    //this.refs.price_500.style.border = '1px solid #dce4e6';
    //this.refs.price_1000.style.border = '1px solid #dce4e6';
    //this.refs.price_2000.style.border = '1px solid #dce4e6';
    //$('button i').hide();
    const price = this.refs.priceInput.value;
    const brand = this.props.profileData.get('brand');
    const recharge_min_budget = parseInt(brand.get("recharge_min_budget"));
    const promotion = this.props.profileData.get('promotion');
    const promotion_rate = !!promotion ? promotion.get('rate') : 0;
    const promotion_min_budget = !!promotion ? parseInt(promotion.get('min_credit')) : 0;
    console.log(promotion_min_budget);
    console.log(price >= promotion_min_budget);
    if(validator.isNull(price)) {
      $(".error-tips p").hide();
      $(".must-input").show();
      this.setState({
        creditPoints: 0
      });
    } else if(!validator.isInt(price)) {
      $(".error-tips p").hide();
      $(".must-be-integer").show();
      this.setState({
        creditPoints: 0
      });
    } else if(!validator.isInt(price, {min: recharge_min_budget})) {
      $(".error-tips p").hide();
      $(".must-greater-than").show();
      this.setState({
        creditPoints: 0
      });
    } else if(!!validator.isInt(price, {min: recharge_min_budget}) && price < promotion_min_budget) {
      $(".error-tips p").hide();
      $(".promotion-greater-than").show();
      this.setState({
        creditPoints: 0
      });
    } else {
      $(".error-tips p").hide();
      this.setState({
        // creditPoints: Math.round(price * promotion_rate)
        creditPoints: Math.floor(price * promotion_rate)
      });
    }
  }

  recharge() {
    const price = this.refs.priceInput.value;
    const invite_code = this.refs.marketingInviteCode.value;
    // 判断金额是否符合要求: 金额必须存在 金额为整数  大于500元  选项框和input不可共存
    let checked_price = "";
    let credits = "";
    //if (this.refs.price_500.style.borderColor === "rgb(40, 182, 187)") {
    //  checked_price = '500';
    //} else if (this.refs.price_1000.style.borderColor === "rgb(40, 182, 187)") {
    //  checked_price = '1000';
    //} else if (this.refs.price_2000.style.borderColor === "rgb(40, 182, 187)") {
    //  checked_price = '2000';
    //}
    if (validator.isNull(price) && validator.isNull(checked_price)) {
      $(".error-tips p").hide();
      $(".must-input-or-check").show();
      return ;
    } else if (!validator.isNull(price) && validator.isNull(checked_price)) {
      credits = price;
    } else if (validator.isNull(price) && !validator.isNull(checked_price)) {
      credits = checked_price;
    } else if(!validator.isNull(price) && !validator.isNull(checked_price)) {
      return ;
    }

    //if(validator.isNull(credits) || !validator.isInt(credits, {min: 500})) {
    //  return ;
    //}

    this.setState({credits: credits});
    this.setState({inviteCode: invite_code});
    this.setState({showRechargeModal: true});

  }

  render_avatar() {
    const brand = this.props.profileData.get('brand')
    if (brand.get("avatar_url")) {
      return <img ref="avatar" src={brand.get("avatar_url")} className="avatar-img" />
    } else {
      return <img ref='avatar' src={require('brand-profile-pic.jpg')} className="avatar-img" />
    }
  }

  render_min_recharge_budget(){
    const brand = this.props.profileData.get('brand')
    if (brand.get("recharge_min_budget")) {
      return <span className="recharge-min-budget">(最低充值金额: {brand.get("recharge_min_budget")} 元)</span>
    }
  }

  render_promotion() {
    const promotion = this.props.profileData.get('promotion');
    if (!!promotion && promotion.size !== 0) {
      return (
        <div>
          <div className="form-group recharge-form-item">
            <label className="control-label label-small">此次促销活动赠送:</label>
            <div className="col-sm-6 control-box">
              <div className="input-group">
                <input type="text" ref="creditInput" className="form-control input-small points-input" value={this.state.creditPoints} readOnly />
                <span className="input-group-addon">积分（10积分=1元）</span>
              </div>
              <div className="help-block error-tips">
                <p className="promotion-greater-than">充值{promotion.get("min_credit")}元可获赠积分</p>
              </div>
            </div>
          </div>
          <div className="form-group">
            <div className="col-sm-12 form-tips">注意：此次赠送积分有效使用时间至{promotion.get('expired_at')}</div>
          </div>
        </div>
      )
    } else {
      return ''
    }
  }

  componentDidMount() {
    const { fetchBrandPromotion } = this.props.actions;
    fetchBrandPromotion();
  }

  render() {
    const brand = this.props.profileData.get('brand');
    const promotion = this.props.profileData.get('promotion');
    console.log(this.props.profileData);
    // console.log('promotion', promotion.size);
    return (
      <div className="financial page">
        <div className="container">
          <BreadCrumb />
          <div className="page-recharge">
            <FinancialMenu />
            <div className="main-content">
              <div className="account-info-panel">
                <div className="line-title">账户信息</div>

                <div className="media account-info-detail">
                  <div className="media-body infos">
                    <p>
                      <strong>品牌名称：</strong>
                      {brand.get("name")}
                    </p>
                    <p>
                      <strong>公司名称（抬头）：</strong>
                      <span className="company-name">{brand.get("campany_name")}</span>
                      <Link to={`/brand/${brand.get('id')}/edit`}>修改信息</Link>
                    </p>
                    <p>
                      <strong>账户余额：</strong>
                      <span>{brand.get("avail_amount")}</span> &nbsp;元
                    </p>
                    <p>
                      <strong>剩余积分：</strong>
                      <span>{brand.get('credit_amount')}</span> &nbsp;积分
                    </p>
                    {
                      brand.get('credit_amount') === 0 ? '' : (<p className="sm">使用有效期至{brand.get('credit_expired_at')}</p>)
                    }
                  </div>
                  <div className="media-right media-middle">
                    { this.render_avatar() }
                  </div>
                </div>
              </div>

              <div className="account-info-panel">
                <div className="line-title">线上支付</div>

                <div className="recharge-content">
                  {
                    !!promotion && promotion.size !== 0 ? (
                      <div className="promotion-banner">
                        <img ref='' src={require('promotion_banner.jpg')} className="promotion-banner-img" />
                        <div className="banner-info">
                          <h5 className="title">{promotion.get('title')}</h5>
                          <p>{promotion.get('description')}</p>
                        </div>
                      </div>
                    ) : ''
                  }

                  <div className="form-horizontal recharge-form">
                    <div className="form-group recharge-form-item">
                      <label className="control-label">支付方式:</label>
                      <div className="col-sm-3 control-box">
                        <img src={require("alipay.png")} className="recharge-type-img" />
                      </div>
                    </div>
                    <div className="form-group recharge-form-item">
                      <label className="control-label">支付金额:</label>
                      <div className="col-sm-6 control-box">
                        <div className="input-group">
                          <input onInput={this.check_price.bind(this)} ref='priceInput' type="text" className="form-control input-small" placeholder="请输入金额" />
                          <span className="input-group-addon">元</span>
                        </div>
                        <div className="help-block error-tips">
                          <p className="must-input">请输入金额</p>
                          <p className="must-input-or-check">请选择或输入金额</p>
                          <p className="must-be-integer">金额必须为整数</p>
                          <p className="must-greater-than">最低充值金额为{brand.get("recharge_min_budget")}元</p>
                        </div>
                      </div>
                    </div>

                    { this.render_promotion() }

                    <div className="form-group recharge-form-item">
                      <label className="control-label">邀请码(选填):</label>
                      <div className="col-sm-6 control-box">
                        <input ref='marketingInviteCode' type="text" className="form-control input-small" placeholder="请输入邀请码(选填)" />
                      </div>
                    </div>

                    <div className="form-group recharge-form-item mt40">
                      <div className="col-sm-12">
                        <button onClick={this.recharge.bind(this)} className="btn btn-blue btn-default recharge-btn">立即充值</button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/*<div className="recharge-online">
                <div className="detail form-horizontal">
                  <div className="recharge-type">
                    <div className="form-group recharge-amount-item">
                      <label className="col-sm-3 control-label">支付方式:</label>
                      <div className="col-sm-3 control-box">
                        <img src={require("alipay.png")} className="recharge-type-img" />
                      </div>
                    </div>
                  </div>
                  <div className="recharge-amount">
                    <div className="form-group recharge-amount-item">
                      <label className="col-sm-3 control-label">支付金额:</label>
                      <div className="col-sm-3 control-box">
                        <input onInput={this.check_price.bind(this)} ref='priceInput' type="text" className="form-control price-input" placeholder="请输入金额" />

                        <div className="help-block error-tips">
                          <p className="must-input">请输入金额</p>
                          <p className="must-input-or-check">请选择或输入金额</p>
                          <p className="must-be-integer">金额必须为整数</p>
                          <p className="must-greater-than">最低充值金额为{brand.get("recharge_min_budget")}元</p>
                        </div>
                      </div>
                      <div className="col-sm-6 control-box">元</div>
                    </div>

                    <div className="form-group recharge-amount-item">
                      <label className="col-sm-3 control-label">邀请码(选填):</label>
                      <div className="col-sm-3 control-box">
                        <input ref='marketingInviteCode' type="text" className="form-control" placeholder="请输入邀请码(选填)" />
                      </div>
                    </div>

                    <button onClick={this.recharge.bind(this)} className="btn btn-blue btn-default recharge-btn">立即充值</button>
                  </div>
                </div>
              </div>*/}
            </div>
          </div>
        </div>

        <RechargeModal show={this.state.showRechargeModal} onHide={this.closeRechargeModal.bind(this)} actions={this.props.actions} credits={this.state.credits} inviteCode={this.state.inviteCode} />
      </div>
    );
  }
}

export default FinancialRechargePartial;
