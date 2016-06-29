import React from 'react';

export default class CampaignRejectReasons extends React.Component {
  render() {
    const campaign = this.props.campaign;
    return (
      <div className="reject-reasons-group">
        <div className="reject-reasons-text">
          拒绝理由:
        </div>
        <div className="reject-reasons">
          { campaign.get("invalid_reasons") }
        </div>
      </div>
    );
  }
}
