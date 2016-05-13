import React from 'react';

export default class OfflineRecharge extends React.Component {
  render() {
    return (
      <div className="recharge-offline">
        <span>
          <span>线下支付</span>
        </span>

        <div className="detail">
          <table>
            <tbody>
              <tr align="center">
                <td className="account-name row-1">
                  <div>开户名</div>
                </td>
                <td className="account-bank row-1" >
                  <div>开户行</div>
                </td>
                <td className="account-number row-1">
                  <div>帐号</div>
                </td>
              </tr>
              <tr align="center">
                <td className="account-name row-2">
                  <div>罗宾科技(北京)有限公司</div>
                </td>
                <td className="account-bank row-2">
                  <div>中国工商银行</div>
                </td>
                <td className="account-number row-2">
                  <div>62260 10034 23434 2332</div>
                </td>
              </tr>
            </tbody>
          </table>

          <hr />

          <div className="description">
            <p>在转帐或汇款完成后，请您将以下信息，通过邮件发送给 <a href="mailto:payment@robin8.com">payment@robin8.com</a>  或提供给您的
              专属销售人员。我们将在 1-2 个工作日内，为您的帐号完成充值。</p>
            <p>汇款信息：单位名称、汇款银行、汇款账户、汇款金额或直接提供“汇款底单”。</p>
            <p>Robin8帐号信息：Robin8帐号名、联系电话。</p>
            <p>*如有疑问，请致电客服 021-88888888。</p>
            <p>特别提醒：请企业客户线下汇款时、尽可能通过“公司银行账户”汇款，并确保与开具发票公司名称一致，以便您能更方便地开具发票。</p>
          </div>
        </div>
      </div>
    )
  }
}
