import React, { PropTypes } from 'react';
import { Link } from 'react-router';
import _ from 'lodash'
import { showCampaignTypeText, formatDate, campaignStatusHelper, canEditCampaign} from '../../helpers/CampaignHelper'

export default class Campaign extends React.Component {
  static propTypes = {
    campaign: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  renderEditButton(campaign){
    if(canEditCampaign(campaign.get("status"))){
      return <Link to={`/brand/campaigns/${campaign.get("id")}/edit`} className="edit-campaign-btn"></Link>
    }
  }

  render() {

    const { campaign, tagColor, index } = this.props;
    const { campaign_status } = this.props.campaign.get("status");
    return (
      <div className={tagColor} key={index}>
        <div className="brand-activity-content">
          <Link to={`/brand/campaigns/${campaign.get("id")}`} className="detail-link">&gt;</Link>
          <Link to={`/brand/campaigns/${campaign.get("id")}`}>
            <h2 className="activity-title">
              { _.truncate(campaign.get("name"), {'length': 16})}
            </h2>
          </Link>

          { this.renderEditButton(campaign) }
          <small className="date">
            { formatDate(campaign.get("start_time")) } 至 { formatDate(campaign.get("deadline")) }
            &nbsp;&nbsp;按照<span className="campaign-type">{showCampaignTypeText(campaign.get("per_budget_type"))}</span>奖励
          </small>
          <div className="summary">
            { _.truncate(campaign.get("description"), {'length': 120}) }
          </div>
          <ul className="stat-info grid-4">
            <li><span className="txt">已花费</span><strong className="stat-num"><span className="symbol">￥</span>{ campaign.get("take_budget") }</strong></li>
            <li><span className="txt">参与人数</span><strong className="stat-num">{ campaign.get("share_time") }</strong></li>
            <li><span className="txt">点击数</span><strong className="stat-num">{ campaign.get("total_click") }</strong></li>
            <li><span className="txt">剩余天数</span><strong className="stat-num">{ campaign.get("avail_click") }</strong></li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          { campaignStatusHelper(campaign.get("status")) }
          <Link to={`/brand/campaigns/${campaign.get("id")}`} className="detail-link">
            {
              do {
                if(campaign.get('img_url'))
                  <img src={ campaign.get('img_url') } alt="" className="campaign_img" />
                else
                  <img src={ require('campaign-list-pic.jpg') } alt="" className="campaign_img" />
              }
            }

          </Link>

        </div>
      </div>

    );
  }
}
