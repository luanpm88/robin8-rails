import React from 'react';

export default class BudgetPartial extends React.Component {

  render() {
    return (
      <div className="creat-activity-form creat-budget">
        <div className="header">
          <h3 className="tit">推广预算&nbsp;<span className="what">?</span>
          </h3>
        </div>
        <div className="content">
          <div className="spinner-form-area">
            <label>总预算</label>
            <div className="spinner-box">
              <span className="symbol">$</span>
              <input type="text" defaultValue={0} className="spinner-input budget-input" readOnly />
            </div>
            <p className="stat">最低费用<strong className="stat-num">1000</strong>元</p>
          </div>
        </div>
      </div>
    )
  }
}
