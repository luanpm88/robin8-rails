import React from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import moment from 'moment';
import _ from 'lodash';

import "campaign/preview.scss";

import PreviewCommonCampaignPartial from './campaigns/preview/PreviewCommonCampaignPartial';
import PreviewRecruitCampaignPartial from './campaigns/preview/PreviewRecruitCampaignPartial';
import PreviewInviteCampaignPartial from './campaigns/preview/PreviewInviteCampaignPartial';


function select(state) {
  return {
    brand: state.profileReducer.get("brand"),
    campaign: state.campaignReducer.get('campaign')
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

  renderHeader() {
    const campaign = this.props.campaign;
    if (campaign.get('status') == 'unpay') {
      return <p className="confirm-order-text">订单确认</p>
    } else {
      return <p className="confirm-order-text">修改成功</p>
    }
  }

  renderSubmitButton() {
    const campaign = this.props.campaign;
    if (campaign.get('status') === "unpay") {
      return (
        <div className="submit-group">
          <button onClick={this._goPayCampaign} type="submit" className="btn btn-blue btn-lg payCampaignSubmit">立即支付</button>
        </div>
      )
    }
    if (campaign.get('status') === 'unexecute') {
      return (
        <div className="return-back-group">
          <Link to={'/brand/'} className="btn btn-blue btn-lg returnBackBtn"> 修改成功，返回主页</Link>
        </div>
      )
    }
  }

  renderReturnEditBtn() {
    const campaign = this.props.campaign;
    if (campaign.get("per_budget_type") === 'recruit') {
      return <Link to={`/brand/recruits/${campaign.get("id")}/edit`}>返回修改</Link>
    } else if (_.includes(['click', 'post', 'cpa', 'cpi'], campaign.get("per_budget_type"))) {
      return <Link to={`/brand/campaigns/${campaign.get("id")}/edit`}>返回修改</Link>
    } else if (campaign.get("per_budget_type") === 'invite') {
      return <Link to={`/brand/invites/${campaign.get("id")}/edit`}>返回修改</Link>
    }
  }

  renderPreviewPartial() {
    const { brand, campaign } = this.props;
    if (campaign.get("per_budget_type") === 'recruit') {
      return <PreviewRecruitCampaignPartial campaign={campaign} brand={brand} />
    } else if (_.includes(['click', 'post', 'cpa', 'cpi'], campaign.get("per_budget_type"))) {
      return <PreviewCommonCampaignPartial campaign={campaign} brand={brand} />
    } else if (campaign.get("per_budget_type") === 'invite') {
      return <PreviewInviteCampaignPartial campaign={campaign} brand={brand} />
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
          {this.renderHeader()}
          <div className="preview-section">
            {this.renderPreviewPartial()}
            {this.renderSubmitButton()}
          </div>
        </div>
      </div>
    )
  }
}

export default connect(select)(PreviewCampaignPartial)
