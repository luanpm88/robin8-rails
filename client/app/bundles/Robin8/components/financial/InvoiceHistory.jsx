import React from 'react';

export default class InvoiceHistory extends React.Component {
  render() {
    const invoiceHistory = this.props.invoiceHistory
    return (
      <tr align="center">
        <td>
          { invoiceHistory.get("credits") }
        </td>
        <td>
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
        <td>
          <div>
            { invoiceHistory.get("title") }
          </div>
        </td>
        <td>
          <div>
            { invoiceHistory.get("address") }
          </div>
        </td>
        <td>
          <div>
            { invoiceHistory.get("created_at") }
          </div>
        </td>
        <td>
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
        <td>
          {invoiceHistory.get('tracking_number')}
        </td>
      </tr>
    )
  }
}
