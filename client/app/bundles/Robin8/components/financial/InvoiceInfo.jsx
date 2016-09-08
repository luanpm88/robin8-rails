import React from 'react';

import InvoiceInfoModal from './modals/InvoiceInfoModal';
import SpecialInvoiceInfoModal from './modals/SpecialInvoiceInfoModal';
import InvoiceReceiverInfoModal from './modals/InvoiceReceiverInfoModal'

export default class InvoiceInfo extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      showInvoiceInfoModal: false,
      showSpecialInvoiceInfoModal: false,
      showInvoiceReceiverInfoModal: false,
    };
  }

  componentDidMount() {
    const { fetchCommonInvoice, fetchSpecialInvoice, fetchInvoiceReceiver } = this.props.actions;
    fetchCommonInvoice();
    fetchSpecialInvoice();
    fetchInvoiceReceiver();
  }

  closeInvoiceInfoModal() {
    this.setState({showInvoiceInfoModal: false});
  }

  closeSpecialInvoiceInfoModal() {
    this.setState({showSpecialInvoiceInfoModal: false});
  }

  closeInvoiceReceiverModal() {
    this.setState({showInvoiceReceiverInfoModal: false});
  }

  render_common_invoice_title() {
    const invoice = this.props.invoice;
    if (invoice.get('title'))
      return <p>发票抬头: {invoice.get('title')}</p>
    else
      return <p>发票抬头: <span className="no-info">请填写发票抬头</span></p>
  }

  render_receiver_info() {
    const invoiceReceiver = this.props.invoiceReceiver
    if (invoiceReceiver.get('name')) {
      return (
        <div>
          <p>收件人姓名: {invoiceReceiver.get('name')}</p>
          <p>收件人电话: {invoiceReceiver.get('phone_number')}</p>
          <p>收件人地址: {invoiceReceiver.get('address')}</p>
        </div>
      )
    } else {
      return (
        <div>
          <p>收件人姓名: <span className="no-info">请填写收件人姓名</span></p>
          <p>收件人电话: <span className="no-info">请填写收件人电话</span></p>
          <p>收件人地址: <span className="no-info">请填写收件人地址</span></p>
        </div>
      )
    }
  }

  render_save_or_edit_invoice_button() {
    const invoice = this.props.invoice
    if (invoice && invoice.get('title'))
      return <button className="btn edit" onClick={()=>this.setState({showInvoiceInfoModal: true})}>修改</button>
    else
      return <button className="btn save" onClick={()=>this.setState({showInvoiceInfoModal: true})}>创建</button>

  }

  render_save_or_edit_special_invoice_button() {
    const specialInvoice = this.props.specialInvoice;
    if (specialInvoice && specialInvoice.get('title'))
      return <button className="btn edit" onClick={()=>this.setState({showSpecialInvoiceInfoModal: true})}>修改</button>
    else
      return <button className="btn save" onClick={()=>this.setState({showSpecialInvoiceInfoModal: true})}>创建</button>
  }

  render_save_or_edit_invoice_receiver_button() {
    const invoiceReceiver = this.props.invoiceReceiver
    if (invoiceReceiver && invoiceReceiver.get('name')){
      return <button className="btn edit" onClick={()=>this.setState({showInvoiceReceiverInfoModal: true})}>修改</button>
    } else {
      return <button className="btn save" onClick={()=>this.setState({showInvoiceReceiverInfoModal: true})}>创建</button>
    }
  }

  render() {
    const specialInvoice = this.props.specialInvoice;
    return (
      <div>
        <div className="invoice_img">
        {/* <img src={require("financial_invoice_bg.png")} /> */}
        </div>
        <div className="invoice-nav" data-example-id="togglable-tabs">
          <ul className="nav nav-tabs" id="invoice-tabs" role="tablist">
            <li role="presentation" className="active">
              <a href="#common-invoice" id="common-invoice-tab" role="tab" data-toggle="tab" aria-controls="common_invoice" aria-expanded="false">普通增值税发票</a>
            </li>
            <li role="presentation">
              <a href="#special-invoice" id="special-invoice-tab" role="tab" data-toggle="tab" aria-controls="special_invoice" aria-expanded="false">专用增值税发票</a>
            </li>
          </ul>

          <div className="tab-content">
            <div className="tab-pane fade in active" id="common-invoice" aria-labelledby="common-invoice-tab">
              <div className="invoice-table">
                <table>
                  <tbody>
                    <tr align="center">
                      <td className="invoice-info row-1">
                        发票信息
                      </td>
                      <td className="invoice-detail row-1" >
                        <div className="inside-invoice-detail-td">
                          { this.render_common_invoice_title() }
                          <p>发票类型: 普通增值税发票</p>
                        </div>
                      </td>
                      <td className="action row-1">
                        { this.render_save_or_edit_invoice_button() }
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <div className="tab-pane fade" id="special-invoice" aria-labelledby="special-invoice-tab">
              <div className="invoice-table">
                <table>
                  <tbody>
                    <tr align="center">
                      <td className="invoice-info row-1">
                        发票信息
                      </td>
                      <td className="invoice-detail row-1" >
                        <div className="inside-invoice-detail-td">
                          <p>发票抬头: <span className={specialInvoice.get('title') ? null : 'no-info'}> {specialInvoice.get('title') ? specialInvoice.get('title') : '请填写发票抬头'}</span></p>
                          <p>纳税人识别号: <span className={specialInvoice.get('taxpayer_id') ? null : 'no-info'}> {specialInvoice.get('taxpayer_id') ? specialInvoice.get('taxpayer_id') : '请填写纳税人识别号'}</span></p>
                          <p>公司地址: <span className={specialInvoice.get('company_address') ? null : 'no-info'}> {specialInvoice.get('company_address') ? specialInvoice.get('company_address') : '请填写公司地址'}</span></p>
                          <p>公司电话: <span className={specialInvoice.get('company_mobile') ? null : 'no-info'}> {specialInvoice.get('company_mobile') ? specialInvoice.get('company_mobile') : '请填写公司电话'}</span></p>
                          <p>开户行: <span className={specialInvoice.get('bank_name') ? null : 'no-info'}> {specialInvoice.get('bank_name') ? specialInvoice.get('bank_name') : '请填写开户行'}</span></p>
                          <p>开户行帐号: <span className={specialInvoice.get('bank_account') ? null : 'no-info'}> {specialInvoice.get('bank_account') ? specialInvoice.get('bank_account') : '请填写开户行帐号'}</span></p>
                        </div>
                      </td>
                      <td className="action row-1">
                        { this.render_save_or_edit_special_invoice_button() }
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <div className="invoice-receiver-table">
          <table>
            <tbody>
              <tr align="center">
                <td className="express-address row-1">
                  <div>邮寄地址</div>
                </td>
                <td className="receiver-info row-1">
                  <div className="inside-receiver-info-td">
                    { this.render_receiver_info() }
                  </div>
                </td>
                <td className="action row-2">
                  { this.render_save_or_edit_invoice_receiver_button() }
                </td>
              </tr>
            </tbody>
          </table>
        </div>


        <InvoiceInfoModal show={this.state.showInvoiceInfoModal} onHide={this.closeInvoiceInfoModal.bind(this)} actions={this.props.actions}  invoice={this.props.invoice} />
        <SpecialInvoiceInfoModal show={this.state.showSpecialInvoiceInfoModal} onHide={this.closeSpecialInvoiceInfoModal.bind(this)} actions={this.props.actions}  specialInvoice={this.props.specialInvoice} />
        <InvoiceReceiverInfoModal show={this.state.showInvoiceReceiverInfoModal} onHide={this.closeInvoiceReceiverModal.bind(this)} actions={this.props.actions}  invoiceReceiver={this.props.invoiceReceiver} />

      </div>
    )
  }
}
