import React from 'react';

class PreviewInviteCampaignPartial extends React.Component {

  renderAmount() {
    const campaign = this.props.campaign;
    if (campaign.get("status") == 'unpay') {
      if (!!campaign.get("need_pay_amount")) {
        return (
          <div className="acitvity-amount-group">
            <span className="acitvity-amount-text">支付总额:&nbsp;</span>
            <span className="yuan">￥</span>
            <span className="acitvity-amount">{campaign.get("need_pay_amount")}</span>
          </div>
        )
      } else {
        return (
          <div className="acitvity-amount-group">
            <span className="acitvity-amount-text">支付总额:&nbsp;</span>
            <span>等待客服确认价格</span>
          </div>
        )
      }
    }
  }

  render() {
    const { brand, campaign } = this.props;

    return (
      <div className="preview-invite-activity-wrap">
        <div className="activity-detail-info-group" >
          <div className="acitvity-title">
            <p className="activity-description">{ _.truncate(campaign.get("name"), {'length': 18}) }</p>
          </div>
          <div className="acitvity-description-group">
            <p className="acitvity-description-text">活动简介:</p>
            <p className="activity-description">{ _.truncate(campaign.get("description"), {'length': 100}) }</p>
          </div>
          <div className="acitvity-time-range-group">
            <span className="acitvity-time-range-text">活动时间:&nbsp;</span>
            <span className="acitvity-start-time">{campaign.get("start_time")}&nbsp;-&nbsp;</span>
            <span className="acitvity-end-time">{campaign.get("deadline")}</span>
          </div>
          {this.renderAmount()}
        </div>
      </div>
    )
  }
}

export default PreviewInviteCampaignPartial
