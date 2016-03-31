import React from 'react';
import ShowError from '../shared/ShowError';

export default class BudgetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_initTouchSpin', '_handleBudgetInputChange']);
  }

  _initTouchSpin() {
    $('.budget-input').TouchSpin({
      min: 100,
      max: 1000000,
      prefix: '￥'
    })
  }

  _handleBudgetInputChange() {
    const { onChange } = this.props.budget;
    $('.budget-input').change(function() {
      onChange( $(this).val() );
    })
  }

  componentDidMount() {
    this._initTouchSpin()
    this._handleBudgetInputChange()
  }


  renderAvailAmount(){
    return(
      <div>
        <span className="account-balance">余额:</span>
        <strong className="stat-num">
          &nbsp;&nbsp;{1}
        </strong>
        <a href="/contact?from=recharge" target="_blank" className="btn btn-blue btn-default recharge-btn">充值</a>
      </div>
    )
  }

  render() {
    const { budget } = this.props

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
              <input {...budget} type="text" className="spinner-input budget-input" style={{display: 'block'}} />
              <ShowError field={budget}/>
            </div>
            <p className="stat">最低费用<strong className="stat-num">100</strong>元</p>
            { this.renderAvailAmount() }
          </div>
        </div>
      </div>
    )
  }
}
