import React                from 'react';
import { Link }             from 'react-router';
import BreadCrumb           from './shared/BreadCrumb';
import FinancialMenu        from './shared/FinancialMenu';
import Transaction          from './financial/Transaction';
import getUrlQueryParams    from '../helpers/GetUrlQueryParams';

import 'recharge/summary.scss'

class FinancialSummaryPartial extends React.Component {

  componentDidMount() {
    const { fetchTransactions } = this.props.actions;
    const page_params = getUrlQueryParams()["page"]
    const currentPage = page_params ? page_params : 1
    fetchTransactions({page: currentPage});
  }

  componentDidUpdate() {
    this.displayPaginator(this.props)
  }

  displayPaginator(props) {
    const { fetchTransactions } = this.props.actions;
    if (this.props.data.get("paginate").get("X-Page")) {
      const pagination_options = {
        currentPage: this.props.data.get("paginate").get("X-Page"),
        totalPages: this.props.data.get("paginate").get("X-Total-Pages"),
        shouldShowPage: function(type, page, current) {
          switch (type) {
            default:
              return true
          }
        },
        onPageClicked: function(e,originalEvent,type,page){
          fetchTransactions({ page: page });
        }
      }
      $("#transactions-paginator").bootstrapPaginator(pagination_options);
    }
  }

  render_transactions_table() {
    const transactions = this.props.data.get('transactions');
    if (transactions.size) {
      return (
        <table className="table fixed table-bordered">
          <colgroup>
            <col width="199px" />
            <col width="107px" />
            <col width="108px" />
            <col width="108px" />
            <col width="108px" />
            <col width="199px" />
          </colgroup>
          <thead>
            <tr>
              <th className="trade-no">账单编号</th>
              <th className="cost-type">消费类型</th>
              <th className="cost-date">日期</th>
              <th className="cost-price">金额</th>
              <th className="coce">剩余金额</th>
              <th className="cost-remark">备注</th>
            </tr>
          </thead>
          <tbody>
            { do
              {
                if (transactions.size) {
                  transactions.map(function(transaction, index){
                    if (index % 2 === 0) {
                      return <Transaction transaction={transaction} tagColor="ood-transaction" key={index} />
                    } else {
                      return <Transaction transaction={transaction} tagColor="even-transaction" key={index} />
                    }
                  })
                }
              }
            }
          </tbody>
        </table>
      )
    } else {
      return <p className="no-record">暂无消费记录</p>
    }
  }

  render() {

    return (
      <div className="financial page">
        <div className="container">
          <BreadCrumb />
          <div className="page-summary">
            <FinancialMenu />
            <div className="main-content">
              <div className="cost-text">
                <span>
                  <span>消费记录</span>
                </span>
              </div>
              { this.render_transactions_table() }
              <div id="transactions-paginator">
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default FinancialSummaryPartial;
