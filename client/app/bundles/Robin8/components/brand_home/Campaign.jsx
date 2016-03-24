import React, { PropTypes } from 'react';
import { Link } from 'react-router';
import _ from 'lodash'
import format_date from '../shared/DateHelper'
import { showCampaignTypeText } from '../shared/CampaignHelper'

export default class Campaign extends React.Component {
  static propTypes = {
    campaign: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  render() {

    const { campaign, tagColor, index } = this.props;
    const { campaign_status } = this.props.campaign.get("status");
    return (
      <div className={tagColor} key={index}>
        <div className="brand-activity-content">
          <a href="#" className="detail-link">&gt;</a>
          <h2 className="activity-title">
            { campaign.get("name") }
          </h2>

          <Link to={`/brand/campaigns/${campaign.get("id")}/edit`} className="edit-campaign-btn">

          </Link>

          <small className="date">
            { format_date(campaign.get("start_time")) } 至 { format_date(campaign.get("deadline")) }
            &nbsp;&nbsp;按照{showCampaignTypeText(campaign.get("per_budget_type"))}奖励
          </small>
          <div className="summary">
            { _.truncate(campaign.get("description"), {'length': 35}) }
          </div>
          <a href={ campaign.get("url") } className="link" target="_blank">
            { _.truncate(campaign.get("url"), {'length': 54}) }
          </a>

          <ul className="stat-info grid-4">
            <li><span className="txt">已花费</span><strong className="stat-num"><span className="symbol">￥</span>{ campaign.get("per_action_budget") }</strong></li>
            <li><span className="txt">参与人数</span><strong className="stat-num">69876</strong></li>
            <li><span className="txt">点击率</span><strong className="stat-num">???</strong></li>
            <li><span className="txt">剩余天数</span><strong className="stat-num">???</strong></li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          <img className="campaign-status-img" src={ require(`campaign_status_approved.png`) } />
          <img src={ campaign.get('img_url') } alt="活动图片" />
        </div>
      </div>

    );
  }
}
