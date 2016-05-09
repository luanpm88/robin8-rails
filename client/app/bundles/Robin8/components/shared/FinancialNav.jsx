import React from 'react';
import { Link } from 'react-router'


export default class FinancialNav extends React.Component {

  componentDidMount() {
    const path = window.location.pathname;
    if(path.includes('summary')) {
      $('.menu a:nth-child(2)').css("color", "#181616").css('background-color', '#fff');
    } else if(path.includes('invoice')) {
      $('.menu a:nth-child(3)').css("color", "#181616").css('background-color', '#fff');
    } else {
      $('.menu a:nth-child(1)').css("color", "#181616").css('background-color', '#fff');
    }
  }

  handleClick(e) {
    $('.menu a').css("color", "#fff").css('background-color', '#181616');
    e.target.style.backgroundColor = '#fff'
    e.target.style.color = '#181616'
  }

  render() {
    return (
      <div className="menu">
        <ul className="list-inline">
          <Link to={'/brand/financial/'} onClick={this.handleClick.bind(this)}>
            账户充值
          </Link>
          <Link to={'/brand/financial/summary'} onClick={this.handleClick.bind(this)}>
            消费记录
            </Link>
          <Link to={'/brand/financial/invoice'} onClick={this.handleClick.bind(this)}>
            申请发票
          </Link>
        </ul>
      </div>
    );
  }
}
