import React                from 'react';
import { Link }             from 'react-router';
import { connect } from 'react-redux'

import BreadCrumb           from './shared/BreadCrumb';
import FinancialMenu        from './shared/FinancialMenu';
import TransactionCredits          from './financial/TransactionCredits';
import getUrlQueryParams    from '../helpers/GetUrlQueryParams';

import 'recharge/summary.scss'

function select(state) {
  return {
    credits: state.financialReducer.get('credits'),
    paginate: state.financialReducer.get("paginate")
  }
}

class FinancialSummaryCreditsPartial extends React.Component {
  componentDidMount() {
    const { fetchCredits } = this.props.actions;
    const page_params = getUrlQueryParams()["page"]
    const currentPage = page_params ? page_params : 1
    fetchCredits({page: currentPage});
  }

  componentDidUpdate() {
    this.displayPaginator(this.props);
    this.hide_or_show_paginator();
  }

  hide_or_show_paginator() {
    console.log(this.props.credits.size);
    if (!this.props.credits.size) {
      $("#transactions-paginator").hide();
    } else {
      $("#transactions-paginator").show();
    }
  }

  displayPaginator(props) {
    const { fetchCredits } = this.props.actions;
    if (this.props.paginate.get("X-Page")) {
      let totalPage = this.props.paginate.get("X-Total-Pages")
      if (totalPage < this.props.paginate.get("X-Page")){
        totalPage = this.props.paginate.get("X-Page")
      }
      const pagination_options = {
        currentPage: this.props.paginate.get("X-Page"),
        totalPages: totalPage,
        shouldShowPage: function(type, page, current) {
          switch (type) {
            default:
              return true
          }
        },
        onPageClicked: function(e,originalEvent,type,page){
          fetchCredits({ page: page });
        }
      }
      $("#transactions-paginator").bootstrapPaginator(pagination_options);
    }
  }

  render_transactions_table() {
    const credits = this.props.credits;
    console.log(credits);
    if (credits.size) {
      return (
        <table className="table fixed table-bordered">
          <thead>
            <tr>
              <th width="28%" className="trade-no">积分编号</th>
              <th width="12%" className="cost-type">消费类型</th>
              <th width="12%" className="cost-date">日期</th>
              <th width="11%" className="cost-price">积分</th>
              <th width="11%" className="coce">剩余积分</th>
              <th width="26%" className="cost-remark">备注</th>
            </tr>
          </thead>
          <tbody>
            { do
              {
                if (credits.size) {
                  credits.map(function(transaction, index){
                    if (index % 2 === 0) {
                      return <TransactionCredits transaction={transaction} tagColor="ood-transaction" key={index} />
                    } else {
                      return <TransactionCredits transaction={transaction} tagColor="even-transaction" key={index} />
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
                  <span>积分记录</span>
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

export default connect(select)(FinancialSummaryCreditsPartial);
