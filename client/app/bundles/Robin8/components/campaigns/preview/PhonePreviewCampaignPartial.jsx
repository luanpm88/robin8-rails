import React from 'react';
import moment from 'moment';
import "moment-duration-format";


import { showCampaignTypeText } from '../../../helpers/CampaignHelper'

export default class PhonePreviewCampaignPartial extends React.Component {

  renderShareDescription() {
    const { campaign } = this.props;
    if (campaign.get('per_budget_type') == 'click') {
      return <p>分享后好友点击此文章即可获得报酬</p>
    } else if (campaign.get("per_budget_type") == 'post' ) {
      return <p>转发此文章 立即获得报酬</p>
    } else if (campaign.get("per_budget_type") == 'recruit') {
      return <p>参与招募活动获得奖励</p>
    } else if (campaign.get("per_budget_type") == 'simple_cpi') {
      return <p>下载APP, 立即获取报酬</p>
    } else if (campaign.get("per_budget_type") == 'cpi') {
      return <p>邀请好友下载APP立即获得奖励</p>
    } else if (campaign.get("per_budget_type") == 'cpa') {
      return <p>分享后好友完成指定任务立即获得报酬</p>
    }
  }

  renderTime() {
    const campaign = this.props.campaign;
    const now = moment(Date.now());
    const deadline = moment(campaign.get('deadline'));
    const minutes = deadline.diff(now, 'minutes');
    const remain_time = moment.duration(minutes, "minutes").format("d[天]h[小时]m[分钟]");
    if (now < deadline) {
      return <p>距结束{remain_time}</p>
    } else {
      return <p>已结束</p>
    }

  }

  render() {
    const { campaign, brand } = this.props;

    return (
      <div className="phone-preview-campaign">
        <div className="detail-info-group">
          <div className="campaign-header">
            <p className="brand-name">{brand.get("name")}</p>
            <img className="campaign-img" src={ campaign.get('img_url') } />
          </div>
          <div className="campaign-detail">
            <p className="campaign-name">{campaign.get("name")}</p>
            <p className="brand-name">{brand.get("name")}</p>
            <p className="time">{campaign.get("start_time")}&nbsp;-&nbsp;{campaign.get("deadline")}</p>
            <p className="description">{campaign.get("description")}</p>
          </div>

          <div className="budget-info">
            <p>{showCampaignTypeText(campaign.get("per_budget_type"))} | ￥{campaign.get("per_action_budget")}</p>
            <div className="share-description">
              {this.renderShareDescription()}
              {this.renderTime()}
            </div>
          </div>

          <div className="next-and-submit">
            <div className="next">
              <span>推广内容详情</span>
              <span className="glyphicon glyphicon-menu-down" aria-hidden="true"></span>
            </div>
            <div className="share-btn">立即分享</div>
          </div>
        </div>
        <p className="preview-text">预览效果</p>
      </div>
    )
  }
}
