import React from 'react';
import { ShowError, BudgetShowError } from '../shared/ShowError';

export default class RecruitBudgetPartial extends React.Component{
  constructor(props, context){
    super(props, context);
    _.bindAll(this, ['_initTouchSpin', '_handleBudgetInputChange']);
  }

  _initTouchSpin() {
    $('.budget-input').TouchSpin({
      min: 100,
      max: 1000000,
      prefix: '￥'
    })
    $(".recruit-person-count-input").TouchSpin({
      min: 1,
      max: 1000,
      prefix: ""
    })
    $(".spinner-box").find(".bootstrap-touchspin-down").html("")
    $(".spinner-box").find(".bootstrap-touchspin-up").html("")
  }

  _handleBudgetInputChange() {
    const { onChange } = this.props.budget;
    $('.budget-input').change(function() {
      onChange( $(this).val() );
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
    const { budget } = this.props;
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
                <input {...budget} type="text" className="  spinner-input common-spinner-input recruit-person-count-input" style={{display: 'block'}} />
              </div>
            </div>
            <div className="budget-box">
              <label className="creat-campaign-total-budget form-common-label">人均奖励</label>
              <div className="spinner-box">
                <input {...budget} type="text" className="spinner-input budget-input common-spinner-input" style={{display: 'block'}} />
              </div>
            </div>
            <div className="budget-box">
              <label className="creat-campaign-total-budget form-common-label">招募预算</label>
              <div className="spinner-box">
                <label type="text" className="" style={{display: 'block'}} >￥0</label>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}