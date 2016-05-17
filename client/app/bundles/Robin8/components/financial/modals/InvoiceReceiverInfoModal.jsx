import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import validator from 'validator';

export default class InvoiceReceiverInfoModal extends Component {

  handleClick() {
    const onHide = this.props.onHide;
    const nameInput = this.refs.invoiceReceiverNameInput.value.trim()
    const mobileInput = this.refs.invoiceReceiverMobileInput.value.trim();
    const addressInput = this.refs.invoiceReceiverAddressInput.value.trim();
    const invoiceReceiver = this.props.invoiceReceiver
    const saveInvoiceReceiver = this.props.actions.saveInvoiceReceiver;
    const updateInvoiceReceiver = this.props.actions.updateInvoiceReceiver;
    if (validator.isNull(nameInput)){
      $('.name-error-tip').show();
    } else if (!validator.isMobilePhone(mobileInput, 'zh-CN')){
      $('.mobile-error-tip').show();
    } else if (validator.isNull(addressInput)){
      $('.address-error-tip').show();
    } else {
      if (invoiceReceiver.get('name')){
        updateInvoiceReceiver(nameInput, mobileInput, addressInput);
      } else {
        saveInvoiceReceiver(nameInput, mobileInput, addressInput);
      }
      onHide();
    }
  }

  handleChange() {
    if (!validator.isNull(this.refs.invoiceReceiverNameInput.value.trim())) {
      $('.name-error-tip').hide();
    }
    if (validator.isMobilePhone(this.refs.invoiceReceiverMobileInput.value.trim(), 'zh-CN')) {
      $('.mobile-error-tip').hide();
    }
    if (!validator.isNull(this.refs.invoiceReceiverAddressInput.value.trim())) {
      $('.address-error-tip').hide();
    }
  }

  handleNameBlur(e) {
    const invoice = this.props.invoice;
    this.refs.invoiceReceiverNameInput.value = e.target.value;
  }

  handleMobileBlur(e) {
    const invoice = this.props.invoice;
    this.refs.invoiceReceiverMobileInput.value = e.target.value;
  }

  handleAddressBlur(e) {
    const invoice = this.props.invoice;
    this.refs.invoiceReceiverAddressInput.value = e.target.value;
  }

  render() {
    return (
      <Modal {...this.props} className="invoice-receiver-info-modal">
        <Modal.Header closeButton>
          <Modal.Title>邮寄信息</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className='clearfix'>
            <p className='invoice-receiver-name'>收件人姓名</p>
            <input ref='invoiceReceiverNameInput' onChange={this.handleChange.bind(this)} onBlur={this.handleNameBlur.bind(this)} className='invoice-receiver-name-input' type="text" defaultValue={this.props.invoiceReceiver.get('name')} />
            <p className="name-error-tip" style={{display: 'none'}}>收件人姓名不能为空</p>
          </div>
          <div className='clearfix'>
            <p className='invoice-receiver-mobile'>收件人电话</p>
            <input ref='invoiceReceiverMobileInput' onChange={this.handleChange.bind(this)} onBlur={this.handleMobileBlur.bind(this)} className='invoice-receiver-mobile-input' type="text" defaultValue={this.props.invoiceReceiver.get('phone_number')} />
            <p className="mobile-error-tip" style={{display: 'none'}}>收件人电话格式不正确</p>
          </div>
          <div className='clearfix'>
            <p className='invoice-receiver-address'>收件人地址</p>
            <input ref='invoiceReceiverAddressInput' onChange={this.handleChange.bind(this)} onBlur={this.handleAddressBlur.bind(this)} className='invoice-receiver-address-input' type="text" defaultValue={this.props.invoiceReceiver.get('address')} />
            <p className="address-error-tip" style={{display: 'none'}}>收件人地址不能为空</p>
          </div>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.handleClick.bind(this)}>确定</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
