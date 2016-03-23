import React, { PropTypes } from "react";
import { showCampaignTypeText, formaDate } from "../../helpers/CampaignHelper";

export default class Basic extends React.Component {
  constructor(props, context){
    super(props, context)
  }

  render(){
    const { campaign } = this.props
    return (
      <div className="brand-activity-card brand-activity-card-detail">
        <div className="brand-activity-content">
          <a href="#" className="btn btn-default btn-red btn-line stop-btn">编辑</a>
          <h2 className="activity-title">{ campaign.get("name") }</h2>
          <small className="date">最后更新: { formaDate(campaign.get("updated_at")) }, 按照{showCampaignTypeText(campaign.get("per_budget_type"))}奖励 </small>
          <div className="summary">描述: <span className="summary">{ campaign.get("description") }</span></div>
          <a href="#" className="link">{ campaign.get("url") }</a>
          <ul className="stat-info grid-3">
            <li><span className="txt">起止时间</span><small className="date">{ formaDate(campaign.get("created_at")) } - { formaDate(campaign.get("deadline ")) }</small></li>
            <li><span className="txt">总预算</span><strong className="stat-num"><sapn className="symbol">$</sapn>{ campaign.get("budget") }</strong></li>
            <li><span className="txt">一次{showCampaignTypeText(campaign.get("per_budget_type"))}</span><strong className="stat-num"><sapn className="symbol">$</sapn>{ campaign.get("per_action_budget") }</strong></li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          <img src={ campaign.get("img_url") } alt={ campaign.get("name") } />
        </div>
      </div>
    );
  }  
}