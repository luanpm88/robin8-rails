import React from 'react';

import InvoiceInfoModal from './modals/InvoiceInfoModal';
import InvoiceReceiverInfoModal from './modals/InvoiceReceiverInfoModal'

export default class InvoiceInfo extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      showInvoiceInfoModal: false,
      showInvoiceReceiverInfoModal: false,
    };
  }

  componentDidMount() {
    const { fetchInvoice, fetchInvoiceReceiver } = this.props.actions;
    fetchInvoice();
    fetchInvoiceReceiver();
  }

  closeInvoiceInfoModal() {
    this.setState({showInvoiceInfoModal: false});
  }

  closeInvoiceReceiverModal() {
    this.setState({showInvoiceReceiverInfoModal: false});
  }

  render_title() {
    const invoice = this.props.invoice
    if (invoice.get('title'))
      return <p>发票抬头: {invoice.get('title')}</p>
    else
      return <p>发票抬头: </p>
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
          <p>收件人姓名:</p>
          <p>收件人电话:</p>
          <p>收件人地址:</p>
        </div>
      )
    }
  }

  render_save_or_edit_invoice_button() {
    const invoice = this.props.invoice
    if (invoice.get('title'))
      return <button className="btn edit" onClick={()=>this.setState({showInvoiceInfoModal: true})}>修改</button>
    else
      return <button className="btn save" onClick={()=>this.setState({showInvoiceInfoModal: true})}>创建</button>

  }

  render_save_or_edit_invoice_receiver_button() {
    const invoiceReceiver = this.props.invoiceReceiver
    if (invoiceReceiver.get('name'))
      return <button className="btn edit" onClick={()=>this.setState({showInvoiceReceiverInfoModal: true})}>修改</button>
    else
      return <button className="btn save" onClick={()=>this.setState({showInvoiceReceiverInfoModal: true})}>创建</button>
  }

  render() {
    return (
      <div>
        <div className="invoice_img">
          <img src={require("financial_invoice_bg.png")} />
        </div>
        <div className="invoice-table">
          <span className="title" >申请发票</span>
          <table>
            <tbody>
              <tr align="center">
                <td className="invoice-info row-1">
                  发票信息
                </td>
                <td className="invoice-detail row-1" >
                  <div>
                    { this.render_title() }
                    <p>发票类型: 普通增值税发票</p>
                  </div>
                </td>
                <td className="action row-1">
                  { this.render_save_or_edit_invoice_button() }
                </td>
              </tr>
              <tr align="center">
                <td className="express-address row-2">
                  <div>邮寄地址</div>
                </td>
                <td className="receiver-info row-2">
                  { this.render_receiver_info() }
                </td>
                <td className="action row-2">
                  { this.render_save_or_edit_invoice_receiver_button() }
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <InvoiceInfoModal show={this.state.showInvoiceInfoModal} onHide={this.closeInvoiceInfoModal.bind(this)} actions={this.props.actions}  invoice={this.props.invoice} />
        <InvoiceReceiverInfoModal show={this.state.showInvoiceReceiverInfoModal} onHide={this.closeInvoiceReceiverModal.bind(this)} actions={this.props.actions}  invoiceReceiver={this.props.invoiceReceiver} />

      </div>
    )
  }
}
