import React from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import moment from 'moment';
import _ from 'lodash';

import "campaign/preview.scss";

import PreviewCommonCampaignPartial from './campaigns/preview/PreviewCommonCampaignPartial';

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
    const campaign = this.props.campaign;
    if (campaign.get('status') ==="unpay") {
      return <button onClick={this._goPayCampaign} type="submit" className="btn btn-blue btn-lg payCampaignSubmit">立即支付</button>
    }
    if (campaign.get('status') === 'unexecute') {
      return <Link to={'/brand/'} className="btn btn-blue btn-lg"> 返回</Link>
    }
  }

  renderReturnEditBtn() {
    const campaign = this.props.campaign;
    if (campaign.get("per_budget_type") === 'recruit') {
      return <Link to={`/brand/recruits/${campaign.get("id")}/edit`}>返回修改</Link>
    } else if (_.includes(['click', 'post', 'cpa'], campaign.get("per_budget_type"))) {
      return <Link to={`/brand/campaigns/${campaign.get("id")}/edit`}>返回修改</Link>
    }
  }

  renderPreviewPartial() {
    const campaign = this.props.campaign;
    if (campaign.get("per_budget_type") === 'recruit') {
      return <PreviewCommonCampaignPartial campaign={campaign} />
    } else if (_.includes(['click', 'post', 'cpa'], campaign.get("per_budget_type"))) {
      return <PreviewCommonCampaignPartial campaign={campaign} />
    }
  }

  render() {
    const campaign = this.props.campaign

    return (
      <div className="page page-activity page-activity-preview">
        <div className="container">
          <ol className="breadcrumb">
            <li>
              <i className="caret-arrow left" />
              {this.renderReturnEditBtn()}
            </li>
          </ol>
          {this.renderPreviewPartial()}
          {this.renderSubmitButton()}
        </div>
      </div>
    )
  }
}

export default connect(select)(PreviewCampaignPartial)
