import React from 'react';

export default class CampaignRejectReasons extends React.Component {
  render() {
    const campaign = this.props.campaign;
    return (
      <ol className="reject-reasons">
      {
        do {
          campaign.get("invalid_reasons").map(function(reason, index) {
            return <li key={index}>{reason}</li>
          })
        }
      }
      </ol>
    );
  }
}
