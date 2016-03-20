import React from 'react';

export default class BudgetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_initTouchSpin', '_handleBudgetInputChange']);
  }

  _initTouchSpin() {
    $('.budget-input').TouchSpin({
      min: 0,
      max: 10000000,
      prefix: '￥'
    })
  }

  _handleBudgetInputChange() {
    const { onChange } = this.props.budget;
    $('.budget-input').change(function() {
      onChange($(this).val());
    })
  }

  componentDidMount() {
    this._initTouchSpin()
    this._handleBudgetInputChange()
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
              <input {...budget} type="text" defaultValue={0} className="spinner-input budget-input" style={{display: 'block'}} />
            </div>
            <p className="stat">最低费用<strong className="stat-num">1000</strong>元</p>
          </div>
        </div>
      </div>
    )
  }
}
