import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import validator from 'validator';

export default class InvoiceInfoModal extends Component {

  handleClick() {
    const onHide = this.props.onHide;
    const invoice = this.props.invoice
    const saveCommonInvoice = this.props.actions.saveCommonInvoice;
    const updateCommonInvoice = this.props.actions.updateCommonInvoice;
    if (validator.isNull(this.refs.invoiceTitleInput.value.trim())){
      $('.error-tip').show();
    } else {
      if (invoice.get('title')){
        updateCommonInvoice(this.refs.invoiceTitleInput.value);
      } else {
        saveCommonInvoice(this.refs.invoiceTitleInput.value);
      }
      onHide();
    }
  }

  handleChange(e) {
    if (!validator.isNull(this.refs.invoiceTitleInput.value.trim())) {
      $('.error-tip').hide();
    }
  }

  handleBlur(e) {
    const invoice = this.props.invoice;
    this.refs.invoiceTitleInput.value = e.target.value;
  }

  render() {
    return (
      <Modal {...this.props} className="invoice-info-modal">
        <Modal.Header closeButton>
          <Modal.Title>普通增值税发票</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="form-group">
            <p className='invoice-label'>发票抬头</p>
            <input ref='invoiceTitleInput' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={ this.props.invoice ? this.props.invoice.get('title') : ''} />
            <p className="error-tip" style={{display: 'none'}}>发票抬头不能为空</p>
          </div>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.handleClick.bind(this)}>确定</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
