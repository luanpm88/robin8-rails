import React from 'react';

export default class TransactionCredits extends React.Component {
  render() {
    const transaction = this.props.transaction;
    let creditsStyle;
    if (transaction.get("direct") == "花费" || transaction.get("direct") == "过期") {
      creditsStyle = {color: 'red'}
    } else if (transaction.get("direct") == "赠送" || transaction.get("direct") == "退还") {
      creditsStyle = {color: 'green'}
    } else {
      creditsStyle = {color: 'black'}
    }
    return (
      <tr className={this.props.tagColor}>
        <td>{transaction.get("trade_no")}</td>
        <td>{transaction.get("direct")}</td>
        <td>{transaction.get("show_time")}</td>
        <td style={creditsStyle} className="credits">{transaction.get("score")}</td>
        <td>{transaction.get("amount")}</td>
        <td dangerouslySetInnerHTML={{ __html: transaction.get("remark")}}></td>
      </tr>
    )
  }
}
