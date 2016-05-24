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
    // const credits = parseInt(this.props.credits);
    // const tax = this.props.checkInvoice ? credits*0.06 : 0;


    const credits = parseFloat(this.props.credits);
    const tax = this.props.checkInvoice ? credits*1 : 0;

    alipayRecharge(credits, tax);
  }

  render() {
    // const credits = parseInt(this.props.credits);
    // const tax = this.props.checkInvoice ? credits*0.06 : 0;

    const credits = parseFloat(this.props.credits);
    const tax = this.props.checkInvoice ? credits*1 : 0;
    
    return (
      <Modal {...this.props} className="invoice-info-modal">
        <Modal.Header closeButton>
          <Modal.Title>支付信息</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div>
            <p className='recharge-amount'>充值金额: {credits}</p>
            <p className='tax-amount'>发票税费: {tax}</p>
            <p className="detail help-block">若您的需要开具发票，我们会按照国家规定征收6%税点，发票税费不计入余额，充值成功后您可以在申请发票模块进行发票申请</p>
          </div>
        </Modal.Body>
        <Modal.Footer>
          <p>支付总计: { credits + tax }</p>
          <Button onClick={this.close.bind(this)}>取消</Button>
          <Button onClick={this.pay.bind(this)}>立即支付</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
