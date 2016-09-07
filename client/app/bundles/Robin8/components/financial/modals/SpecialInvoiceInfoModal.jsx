import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import validator from 'validator';

export default class SpecialInvoiceInfoModal extends Component {

  handleClick() {
    const onHide = this.props.onHide;
    const specialInvoice = this.props.specialInvoice;
    const saveSpecialInvoice = this.props.actions.saveSpecialInvoice;
    const updateSpecialInvoice = this.props.actions.updateSpecialInvoice;
    if (validator.isNull(this.refs.invoiceTitleInput.value.trim())){
      $('.error-tip').show();
    } else {
      if (specialInvoice.get('title')){
        updateCommonInvoice(this.refs.invoiceTitleInput.value);
      } else {
        saveCommonInvoice(this.refs.invoiceTitleInput.value);
      }
      onHide();
    }
  }

  handleChange(e) {
    $('.modal-body input').each(function() {
      if (!validator.isNull($(this).val().trim())) {
        $(this).next().hide();
      }
    })
  }

  handleBlur(e) {
    const specialInvoice = this.props.specialInvoice;
    this.refs.invoiceTitleInput.value = e.target.value;
  }

  render() {
    console.log(this.props);
    return (
      <Modal {...this.props} className="invoice-info-modal">
        <Modal.Header closeButton>
          <Modal.Title>普通增值税发票</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="form-group">
            <span className='invoice-label'>发票抬头</span>
            <input ref='invoiceTitleInput' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={this.props.specialInvoice ? this.props.specialInvoice.get('title') : ''} />
            <p className="error-tip" style={{display: 'none'}}>发票抬头不能为空</p>
          </div>
          <div className="form-group">
            <span className='invoice-label'>纳税人识别号</span>
            <input ref='taxpayerId' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={this.props.specialInvoice ? this.props.specialInvoice.get('taxpayer_id') : ''} />
            <p className="error-tip" style={{display: 'none'}}>纳税人识别号不能为空</p>
          </div>
          <div className="form-group">
            <span className='invoice-label'>公司名称</span>
            <input ref='companyNameInput' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={this.props.specialInvoice ? this.props.specialInvoice.get('company_name') : ''} />
            <p className="error-tip" style={{display: 'none'}}>公司名称不能为空</p>
          </div>
          <div className="form-group">
            <span className='invoice-label'>地址</span>
            <input ref='companyAddressInput' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={this.props.specialInvoice ? this.props.specialInvoice.get('company_address') : ''} />
            <p className="error-tip" style={{display: 'none'}}>地址不能为空</p>
          </div>
          <div className="form-group">
            <span className='invoice-label'>电话</span>
            <input ref='companyNameInput' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={this.props.specialInvoice ? this.props.specialInvoice.get('company_mobile') : ''} />
            <p className="error-tip" style={{display: 'none'}}>电话不能为空</p>
          </div>
          <div className="form-group">
            <span className='invoice-label'>开户行</span>
            <input ref='BankNameInput' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={this.props.specialInvoice ? this.props.specialInvoice.get('bank_name') : ''} />
            <p className="error-tip" style={{display: 'none'}}>开户行不能为空</p>
          </div>
          <div className="form-group">
            <span className='invoice-label'>银行账号</span>
            <input ref='BankAccountInput' onChange={this.handleChange.bind(this)} onBlur={this.handleBlur.bind(this)} className='invoice-input' type="text" defaultValue={this.props.specialInvoice ? this.props.specialInvoice.get('bank_account') : ''} />
            <p className="error-tip" style={{display: 'none'}}>银行账号不能为空</p>
          </div>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.handleClick.bind(this)}>确定</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
