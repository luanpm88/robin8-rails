import React from 'react';
import { Link } from 'react-router';
import BreadCrumb     from './shared/BreadCrumb';
import FinancialMenu  from './shared/FinancialMenu'
import InvoiceInfo from './financial/InvoiceInfo';

import 'recharge/invoice.scss'

class FinancialInvoicePartial extends React.Component {

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
              <p className="avail-invoice-amount">可申请额度: &nbsp;&nbsp;&nbsp;6100元</p>
              <ul className="list-inline">
                <li>
                  申请金额
                </li>
                <li>
                  <input type="text" className="form-control" placeholder="请输入金额" />
                </li>
                <li>
                  <button className="btn btn-blue btn-default">确认提交</button>
                </li>
              </ul>
            </div>

            <div className="apply-invoice-history">
              <table>
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
                  <tr align="center">
                    <td className="invoice-amount">
                      3000.00
                    </td>
                    <td className="invoice-type" >
                      普通增值税发票
                    </td>
                    <td className="invoice-title">
                      上海一二三四五有限公司
                    </td>
                    <td className="invoice-address">
                      上海市静安区江宁路77号
                    </td>
                    <td className="invoice-create_time" >
                      2016年05月02日
                    </td>
                    <td className="express-status">
                      等待寄出
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
    )
  }
}

export default FinancialInvoicePartial;
