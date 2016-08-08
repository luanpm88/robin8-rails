import React, { PropTypes } from "react";
import { Link } from 'react-router';

import { showCampaignTypeText, formatDate, campaignStatusHelper, canEditCampaign, canPayCampaign, isRecruitCampaign, isInviteCampaign} from "../../../helpers/CampaignHelper";

export default class Basic extends React.Component {
  constructor(props, context){
    super(props, context)
  }

  renderEditCampaignButton(campaign){
    if(canEditCampaign(campaign.get("status"))){
      return <Link to={`/brand/campaigns/${campaign.get("id")}/edit`} className="btn btn-default btn-red btn-line stop-btn">编辑</Link>
    } else if (canPayCampaign(campaign.get("status"))) {
      if(isRecruitCampaign(campaign.get("per_budget_type"))) {
        return (
          <div>
            <Link to={`/brand/recruits/${campaign.get("id")}/edit`} className="recruit-before-pay-stop-btn">编辑</Link>
            <Link to={`/brand/recruits/${campaign.get("id")}/preview`} className="btn recruit-pay-stop-btn">支付</Link>
          </div>
        )
      } else if(isInviteCampaign(campaign.get("per_budget_type"))) {
        return (
          <div>
            <Link to={`/brand/invites/${campaign.get("id")}/edit`} className="recruit-before-pay-stop-btn">编辑</Link>
            <Link to={`/brand/invites/${campaign.get("id")}/preview`} className="btn recruit-pay-stop-btn">支付</Link>
          </div>
        )
      } else {
        return (
          <div>
            <Link to={`/brand/campaigns/${campaign.get("id")}/edit`} className="recruit-before-pay-stop-btn">编辑</Link>
            <Link to={`/brand/campaigns/${campaign.get("id")}/preview`} className="btn recruit-pay-stop-btn">支付</Link>
          </div>
        )
      }
    }
  }

  render(){
    const { campaign } = this.props;
    const imgUrl = !!campaign.get('img_url') ? campaign.get('img_url') : require('campaign-list-pic.jpg');

    return (
      <div className="brand-activity-card brand-activity-card-detail">
        <div className="brand-activity-content">
          <h2 className="activity-title">{ campaign.get("name") }<span className="label label-orange">招募</span></h2>
          { this.renderEditCampaignButton(campaign) }
          <small className="duration">{ formatDate(campaign.get("start_time")) } - { formatDate(campaign.get("deadline")) }</small>
          <small className="address">{ campaign.get("address") }</small>
          <small className="summary">{_.truncate(campaign.get("task_description"), {'length': 120})}</small>

          <ul className="stat-info">
            <li>
              <span className="txt">报名时间</span>
              <small className="date">{ formatDate(campaign.get("recruit_start_time")) } - { formatDate(campaign.get("recruit_end_time")) }</small>
            </li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          { campaignStatusHelper(campaign.get("recruit_status")) }
          <div className="brand-activity-coverphoto-img" style={{ backgroundImage: 'url(' + imgUrl + ')' }}>
          </div>
        </div>
      </div>
    );
  }
}
