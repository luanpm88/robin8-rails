import React from 'react';
import { Link } from 'react-router';
import validator from 'validator';

import BreadCrumb     from './shared/BreadCrumb';
import FinancialMenu  from './shared/FinancialMenu'
import InvoiceInfo from './financial/InvoiceInfo';
import InvoiceHistory from './financial/InvoiceHistory';
import getUrlQueryParams    from '../helpers/GetUrlQueryParams';

import 'recharge/invoice.scss'

class FinancialInvoicePartial extends React.Component {

  componentDidMount() {
    const { fetchAppliableCredits, fetchInvoiceHistories} = this.props.actions;
    const page_params = getUrlQueryParams()["page"]
    const currentPage = page_params ? page_params : 1
    fetchInvoiceHistories({page: currentPage});
    fetchAppliableCredits();
  }

  componentDidUpdate() {
    this.displayPaginator(this.props);
    this.hide_or_show_paginator();
  }

  hide_or_show_paginator() {
    if (!(this.props.data.get("invoiceHistories").size)) {
      $("#invoice-paginator").hide();
    } else {
      $("#invoice-paginator").show();
    }
  }

  displayPaginator(props) {
    const { fetchInvoiceHistories } = this.props.actions;
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
          fetchInvoiceHistories({ page: page });
        }
      }
      $("#invoice-paginator").bootstrapPaginator(pagination_options);
    }
  }

  check_credits() {
    // const { fetchAppliableCredits } = this.props.actions;
    // fetchAppliableCredits();
    // const appliableCredits = this.props.data.get('appliableCredits').get("appliable_credits")
    // const credits = this.refs.creditsInput.value.trim();
    // if (validator.isNull(credits)) {
    //   $(".error-tips p").hide();
    //   $(".must-input").show();
    // } else if(!validator.isInt(credits)) {
    //   $(".error-tips p").hide();
    //   $(".must-be-integer").show();
    // } else if(!validator.isInt(credits, {min: 500})) {
    //   $(".error-tips p").hide();
    //   $(".must-greater-than-500").show();
    // } else if(parseFloat(credits) > parseFloat(appliableCredits)) {
    //   $(".error-tips p").hide();
    //   $(".must-greater-than-appliable-credits").show();
    // } else {
    //   $(".error-tips p").hide();
    // }
  }


  handleClick() {
    const appliableCredits = this.props.data.get('appliableCredits').get("appliable_credits")
    const { fetchAppliableCredits, saveInvoiceHistory} = this.props.actions;

    const credits = this.refs.creditsInput.value.trim();

    // if (validator.isNull(credits) || !validator.isInt(credits) || !validator.isInt(credits, {min: 500}) || (parseFloat(credits) > parseFloat(appliableCredits))) {
    //   return ;
    // }

    if (validator.isNull(credits)) {
      return ;
    }
    saveInvoiceHistory(credits);
    fetchAppliableCredits();
    this.refs.creditsInput.value = ""
  }

  render_invoice_histories_table() {
    const invoiceHistories = this.props.data.get("invoiceHistories");
    if (invoiceHistories && invoiceHistories.size) {
      return (
        <tbody>
          <tr align="center">
            <td className="invoice-amount">
              金额
            </td>
            <td className="invoice-type" >
              类型
            </td>
            <td className="invoice-title">
              抬头
            </td>
            <td className="invoice-address">
              地址
            </td>
            <td className="invoice-create_time" >
              创建时间
            </td>
            <td className="express-status">
              状态
            </td>
          </tr>
          { do
            {
              this.props.data.get("invoiceHistories").map(function(invoiceHistory, index){
                return <InvoiceHistory invoiceHistory={invoiceHistory} key={index} />
              })
            }
          }
        </tbody>
      )
    }
  }

  render_appliable_credits() {
    if (this.props.data.get('appliableCredits').size && (this.props.data.get('appliableCredits').get('appliable_credits') > 0)) {
      return (
        <div>
          <p className="avail-invoice-amount">可申请额度: &nbsp;&nbsp;&nbsp;{this.props.data.get('appliableCredits').get('appliable_credits')}元</p>
          <ul className="list-inline">
            <li>
              申请金额
            </li>
            <li>
              <input onInput={this.check_credits.bind(this)} ref="creditsInput" type="text" className="form-control" placeholder="请输入金额" />
              <span className="yuan">元</span>
            </li>
            <li>
              <button onClick={this.handleClick.bind(this)} className="btn btn-blue btn-default btn-submit">确认提交</button>
            </li>
          </ul>
        </div>
      )
    } else {
      return (<p className="avail-invoice-amount">无可申请发票额度</p>)
    }
  }

  render() {

    return (
      <div className="financial page">
        <div className="container">
          <BreadCrumb />
          <div className="page-invoice">
            <FinancialMenu />
          <div className="main-content">
            <InvoiceInfo invoice={this.props.data.get('invoice')} invoiceReceiver={this.props.data.get('invoiceReceiver')} actions={this.props.actions} />
            <div className='apply-invoice'>
              { this.render_appliable_credits() }

              <div className='error-tips'>
                <p className="must-input">请输入金额</p>
                <p className="must-be-integer">金额必须为整数</p>
                <p className="must-greater-than-500">最小金额为500元</p>
                <p className="must-greater-than-appliable-credits">金额超出了可申请额度</p>
              </div>
            </div>
            <div className="apply-invoice-history">
              <table>
                { this.render_invoice_histories_table() }
              </table>
              <div id="invoice-paginator">
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    )
  }
}

export default FinancialInvoicePartial;
