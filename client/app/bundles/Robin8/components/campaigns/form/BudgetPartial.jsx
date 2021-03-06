import React from 'react';
import { ShowError } from '../../shared/ShowError';
import BudgetAsyncValidate  from '../../shared/validate/BudgetAsyncValidate';

export default class BudgetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_initTouchSpin', '_handleBudgetInputChange']);
  }

  _initTouchSpin(min_budget) {
    $('.budget-input').TouchSpin({
      min: min_budget,
      max: 1000000,
    })
  }

  hideTouchSpinButton() {
    if (this.props.budgetEditable === false) {
      $('.creat-budget .bootstrap-touchspin .bootstrap-touchspin-down').remove()
      $('.creat-budget .bootstrap-touchspin .bootstrap-touchspin-up').remove()
      $(".budget-input").attr('disabled', true);
    }
  }

  _handleBudgetInputChange() {
    const { onChange } = this.props.budget;
    $('.budget-input').change(function() {
      onChange( $(this).val() );
      BudgetAsyncValidate($(this).val());
    })
  }

  componentDidMount() {
    const { budget, min_budget } = this.props
    this._initTouchSpin(min_budget);
    this._handleBudgetInputChange();
  }

  componentWillReceiveProps(nextProps) {
    const { budget, min_budget } = nextProps
    if (min_budget > 100 && budget.value == 100) {
      //if (min_budget > 100 && this.props.min_budget == undefined) {
      budget.onChange(min_budget);
    }
  }

  componentDidUpdate() {
    this.hideTouchSpinButton();
  }

  renderAvailAmount(){
    return(
      <div>
        <span className="account-balance">余额:</span>
        <strong className="stat-num">
          &nbsp;&nbsp;{1}
        </strong>
        <a href="/brand/financial/recharge" target="_blank" className="btn-default recharge-btn">充值</a>
      </div>
    )
  }

  renderMinBudget(){
    const min_budget  = this.props.min_budget
    if(min_budget){
      return <p className="stat">最低费用<strong className="stat-num">{min_budget}</strong>元</p>
    }else{
      return <p></p>
    }


  }

  renderBudgetTips(){
    const tip = "<p>1.&nbsp;为保障活动效果, Robin8每次活动推广费有最低限额。\
                 <p>2.&nbsp;活动发布后, 推广金额将被冻结; 活动结束后, 剩余金额会在4天后返回账户。\
                 <p>3.&nbsp;请注意, 由于账户已充值的余额不能提现, 如您目前账户余额较少, 请尽量在一次活动中用完。"
    return tip
  }

  render() {
    const { budget, min_budget } = this.props
    return (
      <div className="creat-activity-form creat-budget">
        <div className="header">
          <h3 className="tit">推广预算&nbsp;<span className="what" data-toggle="tooltip" title={this.renderBudgetTips()}><span className="question-sign">?</span></span>
          </h3>
        </div>
        <div className="content">
          <div className="spinner-form-area">
            <label className="creat-campaign-total-budget">总预算</label>
            <div className="spinner-box">
              <span className="symbol">$</span>
              <input {...budget} type="text" data-is-edit={this.props.isEdit} data-origin-budget={budget.defaultValue} className="spinner-input budget-input" style={{display: 'block'}} />
            </div>
            {this.renderMinBudget()}
            <ShowError field={budget}/>
            <div><a href="/brand/financial/recharge" className="budget-show-error" target="_blank">账户余额不足, 请充值</a></div>
          </div>
        </div>
      </div>
    )
  }
}
