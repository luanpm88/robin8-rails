import React from 'react';
import { Link } from 'react-router';

export default class FinancialMenu extends React.Component {
  render() {
    return (
      <div className="menu">
        <ul className="list-inline">
          <Link to={'/brand/financial/recharge'}>
            账户充值
          </Link>
          <Link to={'/brand/financial/summary'}>
            消费记录
            </Link>
          <Link to={'/brand/financial/invoice'}>
            申请发票
          </Link>
        </ul>
      </div>
    );
  }
}
