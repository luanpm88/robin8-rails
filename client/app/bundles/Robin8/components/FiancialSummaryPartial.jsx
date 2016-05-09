import React from 'react';
import { Link } from 'react-router';
import BreadCrumb   from './shared/BreadCrumb';

import 'recharge/summary.scss'

class FinacialSummaryPartial extends React.Component {

  render() {
    return (
      <div className="financial page">
        <div className="container">
          <BreadCrumb />
          <div className="page-summary">
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

            <div className="main-content">
              <p>消费记录</p>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default FinacialSummaryPartial;
