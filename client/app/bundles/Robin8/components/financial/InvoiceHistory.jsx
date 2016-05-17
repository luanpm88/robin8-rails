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
          { invoiceHistory.get("title") }
        </td>
        <td className="invoice-address">
          { invoiceHistory.get("address") }
        </td>
        <td className="invoice-create_time" >
          { invoiceHistory.get("created_at") }
        </td>
        <td className="express-status">
          { do
            {
              if (invoiceHistory.get("status") === 'pending'){
                "等待邮寄"
              } else if (invoiceHistory.get("status") === 'passed') {
                "已寄出"
              }
            }
          }
        </td>
      </tr>
    )
  }
}
