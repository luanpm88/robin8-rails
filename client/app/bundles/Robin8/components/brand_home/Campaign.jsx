import React, { PropTypes } from 'react';
import { Link } from 'react-router';
import _ from 'lodash'
import { showCampaignTypeText, formatDate, campaignStatusHelper, canEditCampaign, canPayCampaign, isRecruitCampaign } from '../../helpers/CampaignHelper'

export default class Campaign extends React.Component {
  static propTypes = {
    campaign: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  getUrl() {
    const { campaign } = this.props;

    if(isRecruitCampaign(campaign.get("per_budget_type"))) {
      return `/brand/recruits/${campaign.get("id")}`;
    } else {
      return `/brand/campaigns/${campaign.get("id")}`;
    }
  }

  renderStatusImage() {
    const { campaign } = this.props;

    if(isRecruitCampaign(campaign.get("per_budget_type"))) {
      return campaignStatusHelper(campaign.get("recruit_status"));
    } else {
      return campaignStatusHelper(campaign.get("status"));
    }
  }

  renderEditButton(campaign){
    if(canEditCampaign(campaign.get("status"))){
      return <Link to={this.getUrl() + "/edit"} className="edit-campaign-btn btn">编辑</Link>
    } else if(canPayCampaign(campaign.get("status"))) {
      return (
        <div>
          <Link to={this.getUrl() + "/edit"} className="before-pay-edit-campaign-btn">编辑</Link>
          <Link to={`/brand/campaigns/${campaign.get("id")}/preview`} className="btn pay-campaign-btn">支付</Link>
        </div>
      )
    }
  }

  renderCampaignName(campaign) {
    const padding = canEditCampaign(campaign.get("status")) ? -3 : 0;

    if(isRecruitCampaign(campaign.get("per_budget_type"))) {
      if (canPayCampaign(campaign.get("status"))) {
        return (
          <h2 className="activity-title">
            { _.truncate(campaign.get("name"), {"length": 16 + padding, "omission": ".."})}
            <span className="label label-orange">招募</span>
          </h2>
        )
      } else {
        return (
          <h2 className="activity-title">
            { _.truncate(campaign.get("name"), {"length": 21 + padding, "omission": ".."})}
            <span className="label label-orange">招募</span>
          </h2>
        )
      }
    }
    else {
      if (canPayCampaign(campaign.get("status"))) {
        return (
          <h2 className="activity-title">
            { _.truncate(campaign.get("name"), {'length': 18 + padding, "omission": ".."})}
          </h2>
        )
      } else {
        return (
          <h2 className="activity-title">
            { _.truncate(campaign.get("name"), {'length': 24 + padding, "omission": ".."})}
          </h2>
        )
      }
    }
  }

  renderCampaignDate(campaign) {
    if(isRecruitCampaign(campaign.get("per_budget_type"))) {
      return (
        <small className="date">
          { formatDate(campaign.get("start_time")) } 至 { formatDate(campaign.get("deadline")) }
        </small>
      )
    } else {
      return (
        <small className="date">
            { formatDate(campaign.get("start_time")) } 至 { formatDate(campaign.get("deadline")) }
            &nbsp;&nbsp;按照<span className="campaign-type">{showCampaignTypeText(campaign.get("per_budget_type"))}</span>奖励
        </small>
      )
    }
  }

  renderCampaignAddress(campaign) {
    if(isRecruitCampaign(campaign.get("per_budget_type"))) {
      return (
        <small className="address">
          { campaign.get("address") }
        </small>
      )
    }
  }

  renderCampaignStatInfo(campaign) {
    if(isRecruitCampaign(campaign.get("per_budget_type"))) {
      return (
        <ul className="stat-info grid-4">
          <li>
            <span className="txt">预计招募人数</span>
            <div className="cl-recruiters-count">
              <strong className="stat-num">{ campaign.get("budget") / campaign.get('per_action_budget') }</strong>
            </div>
          </li>
          <li><span className="txt">已招募</span><strong className="stat-num">{ campaign.get("brand_passed_count") }</strong></li>
          <li><span className="txt">人均奖励</span><strong className="stat-num"><span className="symbol">￥</span>{ campaign.get("per_action_budget") }</strong></li>
          <li>
            <span className="txt">招募预算</span>
            <div  className="cl-total-budget">
              <strong className="stat-num"><span className="symbol">￥</span>{ campaign.get("budget") }</strong>
            </div>
          </li>
        </ul>
      )
    } else {
      return (
        <ul className="stat-info grid-4">
          <li><span className="txt">已花费</span><strong className="stat-num"><span className="symbol">￥</span>{ campaign.get("take_budget") }</strong></li>
          <li><span className="txt">参与人数</span><strong className="stat-num">{ campaign.get("share_time") }</strong></li>
          <li><span className="txt">点击数</span><strong className="stat-num">{ campaign.get("total_click") }</strong></li>
          <li>
            <span className="txt">{ campaign.get("per_budget_type") === "post" ? "转发量" : "有效点击"}</span>
            <div  className="remain-time">
              <strong className="stat-num">{campaign.get("per_budget_type") === "post" ? campaign.get("post_count") : campaign.get("avail_click") }</strong>
            </div>
          </li>
        </ul>
      )
    }
  }

  render() {

    const { campaign, tagColor, index } = this.props;
    const imgUrl = !!campaign.get('img_url') ? campaign.get('img_url') : require('campaign-list-pic.jpg');
    const classes = tagColor + " " + (isRecruitCampaign(campaign.get("per_budget_type")) ? "recruit" : "");
    return (
      <div className={classes} key={index}>
        <div className="brand-activity-content">
          <Link to={this.getUrl()} className="link-to-show-page">
            { this.renderCampaignName(campaign) }
          </Link>

          { this.renderEditButton(campaign) }
          { this.renderCampaignDate(campaign) }
          { this.renderCampaignAddress(campaign)}
          <div className="summary">
            { _.truncate(campaign.get("description"), {'length': 120}) }
          </div>
          { this.renderCampaignStatInfo(campaign) }
        </div>
        <div className="brand-activity-coverphoto brand-home-campaign-img pull-left">
          { this.renderStatusImage() }
          <Link to={this.getUrl()} className="detail-link" style={{ backgroundImage: 'url(' + imgUrl + ')' }}>
          </Link>
        </div>
      </div>

    );
  }
}
