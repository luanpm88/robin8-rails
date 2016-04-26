import React from 'react';
import { ShowError, BudgetShowError } from '../shared/ShowError';

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
    const tip = "<p>1.&nbsp;为保障活动效果, Robin8每次活动推广费必须大于100元。\
                 <p>2.&nbsp;活动发布后, 推广金额将被冻结; 活动结束后, 剩余金额会在4天后返回账户。\
                 <p>3.&nbsp;请注意, 由于账户已充值的余额不能提现, 如您目前账户余额大于100且小于200元, 请尽量在一次活动中用完。"
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
        </div>
      </div>
    )
  }
}