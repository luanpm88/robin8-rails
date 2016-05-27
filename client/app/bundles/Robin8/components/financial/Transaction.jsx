import React from 'react';

export default class Transaction extends React.Component {
  render() {
    const transaction = this.props.transaction
    const creditsStyle = transaction.get("direct") == "充值" ? {color: '#489A12'} : {color: '#d33636'}
    return (
      <tr className={this.props.tagColor}>
        <td>{transaction.get("trade_no")}</td>
        <td>{transaction.get("direct")}</td>
        <td>{transaction.get("created_at")}</td>
        <td style={creditsStyle} className="credits">{transaction.get("credits")}</td>
        <td>{transaction.get("avail_amount")}</td>
        <td>
          <div>
            {transaction.get("remark")}
          </div>
        </td>
      </tr>
    )
  }
}
