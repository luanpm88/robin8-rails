import React from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import moment from 'moment';

import "campaign/preview.scss";

import BreadCrumb from './shared/BreadCrumb';

function select(state) {
  return {
    campaign: state.campaignReducer.get('campaign'),
  }
}

class PreviewCampaignPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_goPayCampaign']);
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;
    fetchCampaign(campaign_id);
  }

  _goPayCampaign() {
    const { goPayCampaign } = this.props.actions;
    const campaign = this.props.campaign;
    goPayCampaign(campaign.get("id"));
  }

  componentDidMount() {
    this._fetchCampaign();
  }

  renderSubmitButton() {
    const campaign = this.props.campaign
    if (campaign.get('status') ==="unpay") {
      return <button onClick={this._goPayCampaign} type="submit" className="btn btn-blue btn-lg payCampaignSubmit">立即支付</button>
    }
    if (campaign.get('status') === 'unexecute') {
      return <Link to={'/brand/'} className="btn btn-blue btn-lg"> 返回</Link>
    }
  }

  render() {
    const campaign = this.props.campaign

    return (
      <div className="page page-activity page-activity-preview">
        <div className="container">
         <BreadCrumb />
          <div className="preview-activity-wrap">
            <p>{campaign.get("name")}</p>
            <p>{campaign.get("status")}</p>
            <p className="help-block">跳转到支付页面</p>
            {this.renderSubmitButton()}
          </div>
        </div>
      </div>
    )
  }
}

export default connect(select)(PreviewCampaignPartial)
