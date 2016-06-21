import React from 'react';

class PreviewRecruitCampaignPartial extends React.Component {

  renderAddress() {
    const campaign = this.props.campaign;
    if (campaign.get('address')) {
      return (
        <div className="acitvity-address-group">
          <span className="acitvity-address-text">活动时间:&nbsp;</span>
          <span className="acitvity-address">{campaign.get("address")}</span>
        </div>
      )
    }
  }

  render() {
    const campaign = this.props.campaign;

    return (
      <div className="preview-recruit-activity-wrap">
        <div className="activity-detail-info-group" >
          <div className="acitvity-title">
            <p>{campaign.get("name")}</p>
          </div>
          <div className="acitvity-description-group">
            <p className="acitvity-description-text">活动简介</p>
            <p className="activity-description">{campaign.get("description")}</p>
          </div>
          <div className="acitvity-task-group">
            <p className="acitvity-task-text">活动简介</p>
            <p className="activity-description">{campaign.get("task_description")}</p>
          </div>
          <div className="acitvity-recruit-time-range-group">
            <span className="acitvity-recruit-time-range-text">报名时间:&nbsp;</span>
            <span className="acitvity-recruit-start-time">{campaign.get("recruit_start_time")}&nbsp;-&nbsp;</span>
            <span className="acitvity-recruit-end-time">{campaign.get("recruit_end_time")}</span>
          </div>
          <div className="acitvity-time-range-group">
            <span className="acitvity-time-range-text">活动时间:&nbsp;</span>
            <span className="acitvity-start-time">{campaign.get("start_time")}&nbsp;-&nbsp;</span>
            <span className="acitvity-end-time">{campaign.get("deadline")}</span>
          </div>
          {this.renderAddress()}
          <div className="acitvity-recruit-count-group">
            <span className="acitvity-recruit-count-text">预计招募人数:&nbsp;</span>
            <span className="acitvity-recruit-count">{campaign.get("budget")/campaign.get("per_action_budget")}&nbsp;人</span>
          </div>
          <div className="acitvity-per-budget-group">
            <span className="acitvity-per-budget-text">人均奖励:&nbsp;</span>
            <span className="acitvity-per-budget">{campaign.get("per_action_budget")}&nbsp;元</span>
          </div>
          <div className="acitvity-amount-group">
            <span className="acitvity-amount-text">支付总额:&nbsp;</span>
            <span className="yuan">￥</span>
            <span className="acitvity-amount">{campaign.get("need_pay_amount")}</span>
          </div>
        </div>
      </div>
    )
  }
}

export default PreviewRecruitCampaignPartial
