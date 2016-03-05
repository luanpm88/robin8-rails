import React from 'react';

export default class BudgetPartial extends React.Component {
  render() {
    return (
      <div className="creat-activity-form creat-budget">
        <div className="header">
          <h3 className="tit">推广预算&nbsp;<span className="what">?</span></h3>
        </div>
        <div className="content">
          {/* 预算价格 S */}
          <div className="spinner-form-area">
            <label>总预算</label>
            <div className="spinner-box">
              <span className="symbol">$</span>
              <div className="input-group bootstrap-touchspin"><span className="input-group-btn"><button className="btn btn-default bootstrap-touchspin-down" type="button">-</button></span><span className="input-group-addon bootstrap-touchspin-prefix">$</span><input type="text" defaultValue={0} className="spinner-input budget-input form-control" readOnly style={{display: 'block'}} /><span className="input-group-addon bootstrap-touchspin-postfix" style={{display: 'none'}} /><span className="input-group-btn"><button className="btn btn-default bootstrap-touchspin-up" type="button">+</button></span></div>
            </div>
            <p className="stat">最低费用<strong className="stat-num">1000</strong>元</p>
          </div>
          {/* 预算价格 E */}
        </div>
      </div>
    );
  }
}
