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

    if ($('.check-common').attr('value') === 'common')
      if ($('.need-price-sheet').attr('value') === "false") {
        saveInvoiceHistory(credits, 'common', false);
      } else {
        saveInvoiceHistory(credits, 'common', true);
      }
    else
      if ($('.need-price-sheet').attr('value') === "false" ) {
        saveInvoiceHistory(credits, 'special', false);
      } else {
        saveInvoiceHistory(credits, 'special', true);
      }

    creditsRef.value = "";
    setTimeout(fetchAppliableCredits, 1000);
    this.close();
  }

  chooseInvoiceType() {
    $('.check-common .ok-sign').addClass("checked-img");
    $('.check-common').attr("value", "common");
    $('.check-special').attr("value", "");

    $('.no-price-sheet .ok-sign').addClass("checked-img");
    $('.no-price-sheet').attr("value", "true");
    $('.need-price-sheet').attr("value", "false");

    $('.check-common').on('click', function(){
      $('.check-common').attr("value", "common");
      $('.check-common .ok-sign').addClass("checked-img");
      $('.check-special .ok-sign').removeClass("checked-img");
      $('.check-special').attr("value", "");
    })

    $('.check-special').on('click', function(){
      $('.check-special').attr("value", "special");
      $('.check-special .ok-sign').addClass("checked-img");
      $('.check-common .ok-sign').removeClass("checked-img");
      $('.check-common').attr("value", "");
    })

    $('.no-price-sheet').on('click', function(){
      $('.no-price-sheet').attr("value", "true");
      $('.no-price-sheet .ok-sign').addClass("checked-img");
      $('.need-price-sheet .ok-sign').removeClass("checked-img");
      $('.need-price-sheet').attr("value", "false");
    })

    $('.need-price-sheet').on('click', function(){
      $('.need-price-sheet').attr("value", "true");
      $('.need-price-sheet .ok-sign').addClass("checked-img");
      $('.no-price-sheet .ok-sign').removeClass("checked-img");
      $('.no-price-sheet').attr("value", "false");
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

        <Modal.Header>
          <Modal.Title>是否开报价单</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className='row-1'>
            <span>否</span>
            <div ref='no-price-sheet' className="no-price-sheet">
              <span className="ok-sign"></span>
            </div>
          </div>
          <div className='row-2'>
            <span>是</span>
            <div ref='need-price-sheet' className="need-price-sheet">
              <span className="ok-sign"></span>
            </div>
          </div>
        </Modal.Body>

        <Button className="submit btn-blue btn-default" onClick={this.handleClick.bind(this)}>确定</Button>
      </Modal>
    );
  }
}
