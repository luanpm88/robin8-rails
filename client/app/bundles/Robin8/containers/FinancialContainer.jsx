import React from 'react';
import { Link } from 'react-router';
import _ from 'lodash';

import BreadCrumb   from '../components/shared/BreadCrumb';
import FinancialNav from '../components/shared/FinancialNav'

import 'recharge/financial_nav.scss'

class FinancialContainer extends React.Component {
  render() {
    const childrenWithProps = React.Children.map(this.props.children, (child) =>{
      return React.cloneElement(child, {
        data: this.props.data,
        actions: this.props.actions
      })
    })

    return (
      <div className="financial page">
        <div className="container">
          <BreadCrumb />
          <FinancialNav />
          { childrenWithProps }
        </div>
      </div>
    )
  }
}

export default FinancialContainer;
