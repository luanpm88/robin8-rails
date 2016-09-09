import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import validator from 'validator';

export default class ChooseInvoiceTypeModal extends Component {

  close() {
    const onHide = this.props.onHide;
    onHide();
  }

  handleClick() {
    const { fetchAppliableCredits, saveInvoiceHistory } = this.props.actions;
    const { creditsRef } = this.props;
    const credits = creditsRef.value;

    if ($('.check-common').attr('value') === 'common' && $('.check-special').attr('value') === "") {
      saveInvoiceHistory(credits, 'common');
    }
    if ($('.check-common').attr('value') === '' && $('.check-special').attr('value') === "special") {
      saveInvoiceHistory(credits, 'special');
    }
    creditsRef.value = "";
    setTimeout(fetchAppliableCredits, 1000);
    this.close();
  }

  chooseInvoiceType() {
    $('.check-common .ok-sign').addClass("checked-img");
    $('.check-common').attr("value", "common")
    $('.check-special').attr("value", "")
    $('.check-common').on('click', function(){
      $('.check-common').attr("value", "balance")
      $('.check-common .ok-sign').addClass("checked-img");
      $('.check-special .ok-sign').removeClass("checked-img")
      $('.check-special').attr("value", "")
    })
    $('.check-special').on('click', function(){
      $('.check-special').attr("value", "special")
      $('.check-special .ok-sign').addClass("checked-img");
      $('.check-common .ok-sign').removeClass("checked-img");
      $('.check-common').attr("value", "");
    })
  }

  componentDidUpdate() {
    if(this.props.show) {
      this.chooseInvoiceType();
    }
  }


  render() {

    return (
      <Modal {...this.props} className="choose-invoice-type-modal">
        <Modal.Header closeButton>
          <Modal.Title>选择发票类型</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className='row-1'>
            <span>普通增值税发票</span>
            <div ref='check-common' className="check-common">
              <span className="ok-sign"></span>
            </div>
          </div>
          <div className='row-2'>
            <span>增值税专用发票</span>
            <div ref='check-special' className="check-special">
              <span className="ok-sign"></span>
            </div>
          </div>
        </Modal.Body>
        <div className="total-amount">
          <span>支付总计: </span><span className="price">{  }元</span>
        </div>
        <Button className="pay btn-blue btn-default" onClick={this.handleClick.bind(this)}>立即支付</Button>
      </Modal>
    );
  }
}
