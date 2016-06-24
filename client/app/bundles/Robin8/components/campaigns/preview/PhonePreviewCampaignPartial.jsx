import React from 'react';

export default class PhonePreviewCampaignPartial extends React.Component {

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
            <p>点击 | ￥{campaign.get("per_action_budget")}</p>
            <div className="share-description">
              <p>分享后好友点击此文章即可获得报酬</p>
              <p>距离结束还剩xxx天</p>
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
