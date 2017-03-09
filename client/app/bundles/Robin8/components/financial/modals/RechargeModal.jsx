import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';

export default class RechargeModal extends Component {

  close() {
    const onHide = this.props.onHide;
    onHide();
  }

  pay() {
    const { alipayRecharge } = this.props.actions;
    const credits = parseInt(this.props.credits);
    const inviteCode = this.props.inviteCode;

    alipayRecharge(credits, inviteCode);
    this.close();
  }

  render_invite_code() {
    const inviteCode = this.props.inviteCode;
    if(inviteCode) {
      return <p className="invite-code">邀请码: {inviteCode}</p>
    }
  }

  render_pay_detail() {
    const credits = parseInt(this.props.credits);

    return (
      <div className="no-invoice-content">
        <div className="amount-info">
          <span className="recharge-amount">充值金额: </span>
          <span className="price">{credits}元</span>
          <span className="no-invoice">   (开发票可在“申请发票”模块申请)</span>
        </div>
      </div>
    );
  }

  render() {
    const credits = parseInt(this.props.credits);

    return (
      <Modal {...this.props} className="recharge-modal">
        <Modal.Header closeButton>
          <Modal.Title>充值信息确认</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {this.render_pay_detail()}
          {this.render_invite_code()}
        </Modal.Body>
        <div className="total-amount">
          <span>支付总计: </span><span className="price">{ credits }元</span>
        </div>
        <Button className="pay btn-blue btn-default" onClick={this.pay.bind(this)}>立即支付</Button>
      </Modal>
    );
  }
}
