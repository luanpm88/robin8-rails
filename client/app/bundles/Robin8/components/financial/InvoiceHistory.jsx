import React from 'react';

export default class InvoiceHistory extends React.Component {
  render() {
    const invoiceHistory = this.props.invoiceHistory
    return (
      <tr align="center">
        <td className="invoice-amount">
          { invoiceHistory.get("credits") }
        </td>
        <td className="invoice-type">
          { do
            {
              if (invoiceHistory.get("invoice_type") === 'common'){
                "普通增值税发票"
              } else {
                "增值税专用发票"
              }
            }
          }
        </td>
        <td className="invoice-title">
          <div>
            { invoiceHistory.get("title") }
          </div>
        </td>
        <td className="invoice-address">
          <div>
            { invoiceHistory.get("address") }
          </div>
        </td>
        <td className="invoice-create_time" >
          <div>
            { invoiceHistory.get("created_at") }
          </div>
        </td>
        <td className="express-status">
          { do
            {
              if (invoiceHistory.get("tracking_number")){
                "已邮寄"
              } else {
                "等待邮寄"
              }
            }
          }
        </td>
      </tr>
    )
  }
}
