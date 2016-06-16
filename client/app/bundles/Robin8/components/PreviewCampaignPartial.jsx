import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import moment from 'moment';

import "campaign/preview.scss";

import BreadCrumb     from './shared/BreadCrumb';

function select(state) {
  return {
    campaign: state.campaignReducer.get('campaign'),
  }
}


class CreateCampaignPartial extends React.Component {

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
    goPayCampaign(campaign.get("budget"));
  }

  componentDidMount() {
    this._fetchCampaign();
  }

  render() {
    const campaign = this.props.campaign
    const { saveCampaign } = this.props.actions;

    return (
      <div className="page page-activity page-activity-preview">
        <div className="container">
         <BreadCrumb />
          <div className="creat-activity-wrap">

            <div className="creat-form-footer">
              <p>{campaign.get("name")}</p>
              <p>{campaign.get("status")}</p>
              <p className="help-block">跳转到支付页面</p>
              <button type="submit" onClick={} className="btn btn-blue btn-lg payCampaignSubmit">立即支付</button>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default connect(select)(CreateCampaignPartial)
