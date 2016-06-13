import React from 'react';
import { Link } from 'react-router';
import validator from 'validator';

import BreadCrumb   from './shared/BreadCrumb';
import FinancialMenu  from './shared/FinancialMenu';
import OfflineRecharge from './financial/OfflineRecharge';
import RechargeModal from './financial/modals/RechargeModal';

import 'recharge/recharge.scss';

class FinancialRechargePartial extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      showRechargeModal: false,
      credits: "",
      checkInvoice: false
    };
  }

  closeRechargeModal() {
    this.setState({showRechargeModal: false});
  }

  choose_price(e) {
    this.refs.priceInput.value = "";
    this.refs.price_500.style.border = '1px solid #dce4e6';
    this.refs.price_1000.style.border = '1px solid #dce4e6';
    this.refs.price_2000.style.border = '1px solid #dce4e6';
    $('button i').hide();
    $(".error-tips p").hide();
    if(e.target.value === '500') {
      this.refs.price_500.style.borderColor = "rgb(40, 182, 187)";
      this.refs.price_500.children[0].style.display = "block"
    } else if (e.target.value === '1000') {
      this.refs.price_1000.style.borderColor = "rgb(40, 182, 187)";
      this.refs.price_1000.children[0].style.display = "block"
    } else if (e.target.value === '2000'){
      this.refs.price_2000.style.borderColor = "rgb(40, 182, 187)";
      this.refs.price_2000.children[0].style.display = "block"
    }
  }

  check_price() {
    // 判断金额是否符合要求: 金额必须存在 金额为整数  大于500元
    this.refs.price_500.style.border = '1px solid #dce4e6';
    this.refs.price_1000.style.border = '1px solid #dce4e6';
    this.refs.price_2000.style.border = '1px solid #dce4e6';
    $('button i').hide();
    const price = this.refs.priceInput.value;
    if(validator.isNull(price)) {
      $(".error-tips p").hide();
      $(".must-input").show();
    } else if(!validator.isInt(price)) {
      $(".error-tips p").hide();
      $(".must-be-integer").show();
    } else if(!validator.isInt(price, {min: 500})) {
      $(".error-tips p").hide();
      $(".must-greater-than-500").show();
    } else {
      $(".error-tips p").hide();
    }
  }

  recharge() {
    // // ======
    // // const { alipayRecharge } = this.props.actions;
    // const credits = this.refs.priceInput.value;
    // // ======


    const price = this.refs.priceInput.value;
    // 判断金额是否符合要求: 金额必须存在 金额为整数  大于500元  选项框和input不可共存
    let checked_price = "";
    let credits = "";
    if (this.refs.price_500.style.borderColor === "rgb(40, 182, 187)") {
      checked_price = '500';
    } else if (this.refs.price_1000.style.borderColor === "rgb(40, 182, 187)") {
      checked_price = '1000';
    } else if (this.refs.price_2000.style.borderColor === "rgb(40, 182, 187)") {
      checked_price = '2000';
    }
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

    if(validator.isNull(credits) || !validator.isInt(credits, {min: 500})) {
      return ;
    }

    if(this.refs.invoice_checkbox.checked) {
      this.setState({checkInvoice: true})
    } else {
      this.setState({checkInvoice: false})
    }
    this.setState({credits: credits});
    this.setState({showRechargeModal: true});

  }

  render_avatar() {
    const brand = this.props.profileData.get('brand')
    if (brand.get("avatar_url")) {
      return <img ref="avatar" src={brand.get("avatar_url")} />
    } else {
      return <img ref='avatar' src={require('brand-profile-pic.jpg')} />
    }
  }

  render() {
    const brand = this.props.profileData.get('brand')
    return (
      <div className="financial page">
        <div className="container">
          <BreadCrumb />
          <div className="page-recharge">
            <FinancialMenu />
            <div className="main-content">
              <div className="account-info">
                <span>
                  <span>账户信息</span>
                </span>

                <div className='detail'>
                  { this.render_avatar() }
                  <div>
                    <p className="brand-name">{brand.get("name")}</p>
                    <p className="account-balance">账户余额: <span>{brand.get("avail_amount")}</span> &nbsp;元</p>
                  </div>
                </div>

              </div>

              <div className="recharge-online">
                <span>
                  <span>线上支付</span>
                </span>

                <div className="detail">
                  <div className="recharge-type">
                    <span>支付方式:</span>
                    <img src={require("alipay.png")}/>
                  </div>
                  <div className="recharge-amount">
                    <span>支付金额:</span>
                    <ul className="list-inline">
                      <li>
                        <button value="500" ref='price_500' className='price price-500' onClick={this.choose_price.bind(this)}>
                          500元
                          <i className="icon icon-check"></i>
                        </button>
                      </li>
                      <li>
                        <button value="1000" ref='price_1000' className='price price-1000' onClick={this.choose_price.bind(this)}>
                          1000元
                          <i className="icon icon-check"></i>
                        </button>
                      </li>
                      <li>
                        <button value="2000" ref="price_2000" className='price price-2000' onClick={this.choose_price.bind(this)}>
                          2000元
                          <i className="icon icon-check"></i>
                        </button>
                      </li>
                    </ul>
                    <input onInput={this.check_price.bind(this)} ref='priceInput' type="text" className="form-control" placeholder="请输入金额" />
                    <span className="yuan">元</span>
                    <div className='error-tips'>
                      <p className="must-input">请输入金额</p>
                      <p className="must-input-or-check">请选择或输入金额</p>
                      <p className="must-be-integer">金额必须为整数</p>
                      <p className="must-greater-than-500">最小金额为500元</p>
                    </div>
                    <div>
                      <input ref='invoice_checkbox' type="checkbox" className="choose-invoice" /><span>&nbsp;&nbsp;是否开具发票</span>
                    </div>
                    <button onClick={this.recharge.bind(this)} className="btn btn-blue btn-default recharge-btn">立即充值</button>
                  </div>
                </div>
              </div>


            </div>
          </div>
        </div>

        <RechargeModal show={this.state.showRechargeModal} onHide={this.closeRechargeModal.bind(this)} actions={this.props.actions} credits={this.state.credits} checkInvoice={this.state.checkInvoice} />
      </div>
    )
  }
}

export default FinancialRechargePartial;
