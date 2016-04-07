import React, { PropTypes } from "react";
import { Link } from 'react-router';

import { showCampaignTypeText, formatDate, campaignStatusHelper, canEditCampaign} from "../../helpers/CampaignHelper";

export default class Basic extends React.Component {
  constructor(props, context){
    super(props, context)
  }

  renderCpaActionUrl(campaign) {
    if (campaign.get("per_budget_type") == "cpa"){
      return(
        <div>
        <small className="campaign_action_url">
          <span>CPA地址:</span>
          <a href={ campaign.get("action_url") } className="link" target="_blank">{ campaign.get("action_url") }</a>
        </small>
        <small className="campaign_action_short_url">
          <span>CPA短链:</span>
          <a href="#" className="link">{ campaign.get("short_url") }</a>
        </small>
        </div>
      )
    }
  }

  renderEditCampaignButton(campaign){
    if(canEditCampaign(campaign.get("status"))){
      return <Link to={`/brand/campaigns/${campaign.get("id")}/edit`} className="btn btn-default btn-red btn-line stop-btn">编辑</Link>
    }
  }


  render(){
    const { campaign } = this.props
    return (
      <div className="brand-activity-card brand-activity-card-detail">
        <div className="brand-activity-content">
          <h2 className="activity-title">{ campaign.get("name") }</h2>

          { this.renderEditCampaignButton(campaign) }
          <small className="date">最后更新: { formatDate(campaign.get("updated_at")) }, 按照<span className="campaign-type">{showCampaignTypeText(campaign.get("per_budget_type"))}</span>奖励 </small>

          <small className="summary">{_.truncate(campaign.get("description"), {'length': 120})}</small>
          <small className="campaign_url"><span>活动网址:</span><a href={campaign.get("url")} className="link" target="_blank">{ _.truncate(campaign.get("url"), {'length': 35}) }</a></small>
          {this.renderCpaActionUrl(campaign)}
          <ul className="stat-info grid-3">
            <li><span className="txt">起止时间</span><small className="date">{ formatDate(campaign.get("created_at")) } - { formatDate(campaign.get("deadline")) }</small></li>
            <li><span className="txt">总预算</span><strong className="stat-num"><sapn className="symbol">￥</sapn>{ campaign.get("budget") }</strong></li>
            <li><span className="txt">一次{showCampaignTypeText(campaign.get("per_budget_type"))}</span><strong className="stat-num"><sapn className="symbol">￥</sapn>{ campaign.get("per_action_budget") }</strong></li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          { campaignStatusHelper(campaign.get("status")) }
          <img src={ campaign.get("img_url") } alt={ campaign.get("name") } />
        </div>
      </div>
    );
  }
}
