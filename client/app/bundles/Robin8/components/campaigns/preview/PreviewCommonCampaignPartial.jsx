import React from 'react';

import PhonePreviewCampaignPartial from './PhonePreviewCampaignPartial';

class PreviewCommonCampaignPartial extends React.Component {

  renderAmount() {
    const campaign = this.props.campaign;
    if (campaign.get("status") == 'unpay') {
      return (
        <div className="acitvity-amount-group">
          <span className="acitvity-amount-text">支付总额:&nbsp;</span>
          <span className="yuan">￥</span>
          <span className="acitvity-amount">{campaign.get("need_pay_amount")}</span>
        </div>
      )
    }
  }

  render() {
    const { brand, campaign } = this.props;

    return (
      <div className="preview-activity-wrap">
        <PhonePreviewCampaignPartial campaign={campaign} brand={brand} />
        <div className="activity-detail-info-group" >
          <div className="acitvity-title">
            <p className="activity-description">{ _.truncate(campaign.get("name"), {'length': 18}) }</p>
          </div>
          <div className="acitvity-description-group">
            <p className="acitvity-description-text">活动简介:</p>
            <p className="activity-description">{campaign.get("description")}</p>
          </div>
          <div className="acitvity-time-range-group">
            <p className="acitvity-time-range-text">推广时间:</p>
            <span className="acitvity-start-time">{campaign.get("start_time")}&nbsp;-&nbsp;</span>
            <span className="acitvity-end-time">{campaign.get("deadline")}</span>
          </div>
          <div className="acitvity-budget-group">
            <span className="acitvity-budget-text">单次预算:&nbsp;&nbsp;</span>
            <span className="acitvity-budget">{campaign.get("per_action_budget")}&nbsp;元</span>
          </div>
          {this.renderAmount()}
        </div>
      </div>
    )
  }
}

export default PreviewCommonCampaignPartial
