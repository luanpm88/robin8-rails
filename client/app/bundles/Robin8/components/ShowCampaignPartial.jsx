import React, { Component } from 'react';
import { Link } from 'react-router';
import moment from 'moment';
import { connect } from 'react-redux';

import "campaign/activity/show.scss";

import BreadCrumb               from './shared/BreadCrumb';
import Basic                    from './campaigns/show/Basic';
import Overview                 from './campaigns/show/Overview';
import Target                   from './campaigns/show/Target';
import KolList                  from './campaigns/show/KolList';
import Influnce                 from './campaigns/show/Influnce';
import Install                  from './campaigns/show/Install';
import Evaluation               from './campaigns/show/Evaluation';

import RevokeConfirmModal       from './campaigns/modals/RevokeConfirmModal';

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

function select(state){
  return {
    campaign: state.campaignReducer.get('campaign'),
    campaign_invites: state.campaignReducer.get("campaign_invites"),
    hasfetchedInvite: state.campaignReducer.get("hasfetchedInvite"),
    paginate: state.campaignReducer.get("paginate"),
    campaign_statistics: state.campaignReducer.get("campaign_statistics"),
    campaign_installs: state.campaignReducer.get("campaign_installs")
  };
}

class ShowCampaignPartial extends Component {

  constructor(props, context) {
    super(props, context);
    this.state = {
      showRevokeConfirmModal: false
    };
  }

  closeRevokeConfirmModal() {
    this.setState({showRevokeConfirmModal: false});
  }

  renderRevokeModal() {
    this.setState({showRevokeConfirmModal: true});
  }

  componentDidMount() {
    this._fetchCampaign();
    this.bind_toggle_text();
  }

  componentWillUnmount() {
    this.props.actions.clearCampaign();
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;

    // can load campaign from campaigns
    // const campaigns = this.props.data.get("campaigns");

    fetchCampaign(campaign_id);
  }

  bind_toggle_text() {
    $('.panel').each(function(){
      $(this).on('shown.bs.collapse', function () {
        $(this).find('.switch .txt').text('收起');
      });
      $(this).on('hidden.bs.collapse', function () {
        $(this).find('.switch .txt').text('展开');
      });
    });
  }

  renderRevokeBtn() {
    const campaign = this.props.campaign;
    if (canEditCampaign(campaign.get("status")) || canPayCampaign(campaign.get("status"))) {
      return (
        <div className="revoke-campaign-group">
          <button onClick={this.renderRevokeModal.bind(this)} className="btn revoke-campaign-btn">撤销活动</button>
        </div>
      )
    }
  }

  render() {
    const {campaign, actions, campaign_invites, hasfetchedInvite, paginate, campaign_statistics, campaign_installs} = this.props;
    const campaign_id = this.props.params.id

    return (
      <div className="page page-activity page-activity-show">
        <div className="container">
          <BreadCrumb />
          <Basic {...{campaign}} />
          <Target {...{campaign}} />
          <Overview {...{campaign}} />
          <KolList {...{campaign, actions, campaign_invites, campaign_id, hasfetchedInvite, paginate}} />
          <Influnce {...{campaign, actions, campaign_id, campaign_statistics}} />
          {
            do {
              if(campaign.get("per_budget_type") == "cpi"){
                <Install {...{campaign, actions, campaign_id, campaign_installs}} />
              }
            }
          }
          { this.renderRevokeBtn() }
          <Evaluation {...{campaign, actions, campaign_id}}  />
        </div>
        <RevokeConfirmModal show={this.state.showRevokeConfirmModal} onHide={this.closeRevokeConfirmModal.bind(this)} actions={this.props.actions} campaignId={campaign.get("id")} />
      </div>
    );
  }
}

export default connect(select)(ShowCampaignPartial)
