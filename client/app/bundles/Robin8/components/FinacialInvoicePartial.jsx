import React from 'react';
import { Link } from 'react-router';
import BreadCrumb   from './shared/BreadCrumb';

import 'recharge/invoice.scss'

class FinacialInvoicePartial extends React.Component {
  render() {
    return (
      <div className="financial page">
        <div className="container">
          <BreadCrumb />
          <div className="page-invoice">
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
            <div className="invoice_img">
              <img src={require("financial_invoice_bg.png")} />
            </div>
            <div className="invoice-table">
              <span className="title" >申请发票</span>
              <table>
                <tbody>
                  <tr align="center">
                    <td className="invoice-info row-1">
                      发票信息
                    </td>
                    <td className="invoice-detail row-1" >
                      <div>
                        <p>发票抬头: 罗宾科技(北京)有限公司</p>
                        <p>发票类型: 普通增值税发票</p>
                      </div>
                    </td>
                    <td className="action row-1">
                      <button className="btn edit">修改</button>
                    </td>
                  </tr>
                  <tr align="center">
                    <td className="express-address row-2">
                      <div>邮寄地址</div>
                    </td>
                    <td className="receiver-info row-2">
                      <div>
                        <p>收件人姓名:罗宾科技(北京)有限公司</p>
                        <p>收件人电话:123-456789</p>
                        <p>收件人地址:上海市静安区江宁路77号7楼</p>
                      </div>
                    </td>
                    <td className="action row-2">
                      <button className="btn edit">修改</button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

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

export default FinacialInvoicePartial;
