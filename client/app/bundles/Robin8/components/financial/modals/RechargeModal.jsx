import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import validator from 'validator';

export default class RechargeModal extends Component {

  close() {
    const onHide = this.props.onHide;
    onHide();
  }

  pay() {
    const { alipayRecharge } = this.props.actions;
    const credits = parseInt(this.props.credits);
    const tax = this.props.checkInvoice ? credits*0.06 : 0;


    // const credits = parseFloat(this.props.credits);
    // const tax = this.props.checkInvoice ? credits*1 : 0;
    const need_invoice = this.props.checkInvoice

    alipayRecharge(credits, tax, need_invoice);
    this.close();
  }

  render_pay_detail() {
    const credits = parseInt(this.props.credits);
    const tax = this.props.checkInvoice ? credits*0.06 : 0;

    // const credits = parseFloat(this.props.credits);
    // const tax = this.props.checkInvoice ? credits*1 : 0;

    if (this.props.checkInvoice) {
      return (
        <div>
          <div className="amount-info">
            <span className='recharge-amount'>充值金额: </span><span className='price'>{credits}元</span>
          </div>
          <div className="invoice-info">
            <span className='tax-amount'>发票税费: </span><span className='price'>{tax}元</span>
          </div>
          <p className="detail help-block">若您的需要开具发票，我们会按照国家规定征收6%税点，发票税费不计入余额，充值成功后您可以在申请发票模块进行发票申请</p>
        </div>
      )
    } else {
      return (
        <div className="no-invoice-content">
          <div className="amount-info">
            <span className='recharge-amount'>充值金额: </span>
            <span className='price'>{credits}元</span>
            <span className='no-invoice'>   (不开具发票)</span>
          </div>
        </div>
      )
    }
  }

  render() {
    const credits = parseInt(this.props.credits);
    const tax = this.props.checkInvoice ? credits*0.06 : 0;

    // const credits = parseFloat(this.props.credits);
    // const tax = this.props.checkInvoice ? credits*1 : 0;

    return (
      <Modal {...this.props} className="recharge-modal">
        <Modal.Header closeButton>
          <Modal.Title>充值信息确认</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {this.render_pay_detail()}
        </Modal.Body>
        <div className="total-amount">
          <span>支付总计: </span><span className="price">{ credits + tax }元</span>
        </div>
        <Button className="pay btn-blue btn-default" onClick={this.pay.bind(this)}>立即支付</Button>
      </Modal>
    );
  }
}
