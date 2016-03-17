import React, { PropTypes } from 'react';
import moment from 'moment';

export default class Campaign extends React.Component {
  static propTypes = {
    campaign: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  render() {

    const { campaign, tagColor, index } = this.props
    return (
      <div className={tagColor} key={index}>
        <div className="brand-activity-content">
          <a href="#" className="detail-link">&gt;</a>
          <h2 className="activity-title">
            { campaign.get("name") }
          </h2>
          <small className="date">
            { moment(campaign.get("start_time")).format("D.M.YYYY") } 至 { moment(campaign.get("deadline")).format("D.M.YYYY") }
          </small>
          <div className="summary">
            { campaign.get("description") }
          </div>
          <a href="#" className="link">
            { campaign.get("url") }
          </a>

          <ul className="stat-info grid-4">
            <li><span className="txt">已花费</span><strong className="stat-num"><span className="symbol">￥</span>{ campaign.get("per_action_budget") }</strong></li>
            <li><span className="txt">参与人数</span><strong className="stat-num">69876</strong></li>
            <li><span className="txt">点击率</span><strong className="stat-num">???</strong></li>
            <li><span className="txt">剩余天数</span><strong className="stat-num">???</strong></li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          <img src={ campaign.get('img_url') } alt="活动图片" />
        </div>
      </div>

    );
  }
}