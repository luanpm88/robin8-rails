import React from 'react';
import { ShowError, BudgetShowError } from '../../shared/ShowError';

export default class RecruitBudgetPartial extends React.Component{
  constructor(props, context){
    super(props, context);
    _.bindAll(this, ['_initTouchSpin', '_handleBudgetInputChange']);
  }

  _initTouchSpin() {
    $('.per-action-budget').TouchSpin({
      min: 1,
      max: 1000000,
    })
    $(".recruit-person-count-input").TouchSpin({
      min: 1,
      max: 1000,
    })
    $(".spinner-box").find(".bootstrap-touchspin-down").html("")
    $(".spinner-box").find(".bootstrap-touchspin-up").html("")
  }

  _handleBudgetInputChange() {
    const { per_action_budget } = this.props
    $('.per-action-budget').change(function() {
      per_action_budget.onChange( $(this).val() );
    })

    const { recruit_person_count } = this.props;
    $('.recruit-person-count-input').change(function() {
      recruit_person_count.onChange( $(this).val() );
    })
  }

  componentDidMount() {
    this._initTouchSpin();
    this._handleBudgetInputChange();
  }

  renderBudgetTips(){
    const tip = "<p>1.&nbsp;选择预计招募的人数，以及人均的奖励金额；</p>\
                 <p>2.&nbsp;招募预算总额 = 预计招募人数 x 人均奖励</p>"
    return tip
  }

  render(){
    const { budget, per_action_budget, recruit_person_count} = this.props;
    return(
      <div className="creat-activity-form creat-budget">
        <div className="header">
          <h3 className="tit">招募预算&nbsp;<span className="what" data-toggle="tooltip" title={this.renderBudgetTips()}>?</span>
          </h3>
        </div>
        <div className="content">
          <div className="recruit-budget-form-area">
            <div className="budget-box">
              <label className="creat-campaign-total-budget form-common-label">预计招募人数</label>
              <div className="spinner-box">
                <input {...recruit_person_count} type="text" className="  spinner-input common-spinner-input recruit-person-count-input" style={{display: 'block'}} />
              </div>
            </div>
            <div className="budget-box">
              <label className="creat-campaign-total-budget form-common-label">人均奖励</label>
              <div className="spinner-box">
                <input {...per_action_budget} type="text" className="spinner-input per-action-budget common-spinner-input" style={{display: 'block'}} />
              </div>
            </div>
            <div className="budget-box">
              <label className="creat-campaign-total-budget form-common-label">招募预算</label>
              <div className="spinner-box">
                <label type="text" className="recruit-total-target-label" style={{display: 'block'}} >{(recruit_person_count.value * per_action_budget.value) || 0}</label>
              </div>
            </div>
          </div>
          <div className="recruit-per-budget-price-tip">
            <p className="stat"> Robin8将根据大数据分析结果为不同的KOL呈现不同的价格 </p>
          </div>
        </div>
      </div>
    )
  }
}
