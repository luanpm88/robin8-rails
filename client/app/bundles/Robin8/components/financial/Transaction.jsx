import React from 'react';

export default class Transaction extends React.Component {
  render() {
    const transaction = this.props.transaction;
    let creditsStyle;
    if (transaction.get("direct") == "活动消耗") {
      creditsStyle = {color: 'red'}
    } else if (transaction.get("direct") == "活动取消退还") {
      creditsStyle = {color: 'green'}
    } else {
      creditsStyle = {color: 'black'}
    }
    return (
      <tr className={this.props.tagColor}>
        <td>{transaction.get("trade_no")}</td>
        <td>{transaction.get("direct")}</td>
        <td>{transaction.get("created_at")}</td>
        <td style={creditsStyle} className="credits">{transaction.get("credits")}</td>
        <td>{transaction.get("avail_amount")}</td>
        <td dangerouslySetInnerHTML={{ __html: transaction.get("remark")}}></td>
      </tr>
    )
  }
}
