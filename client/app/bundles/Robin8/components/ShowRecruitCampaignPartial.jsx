import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash';
import moment from 'moment';

import "campaign/recruit/show.scss";

import BreadCrumb  from './shared/BreadCrumb';
import Basic       from './recruit_campaigns/show/Basic';
import ShowMaterialsPartial  from './shared/campaign_material/ShowMaterialsPartial'
import Targets       from './recruit_campaigns/show/Targets';
import Overview    from './recruit_campaigns/show/Overview';
import ResultView  from './recruit_campaigns/show/ResultView';
import KolList     from './recruit_campaigns/show/KolList';
import StateText   from './recruit_campaigns/show/StateText';
import RevokeConfirmModal       from './campaigns/modals/RevokeConfirmModal';

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

function select(state){
  return {
    campaign: state.campaignReducer.get('campaign'),
    campaign_invites: state.campaignReducer.get("campaign_invites"),
    hasfetchedInvite: state.campaignReducer.get("hasfetchedInvite"),
    paginate: state.campaignReducer.get("paginate"),
  };
}

class ShowRecruitCampaignPartial extends Component {

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
    this._fetchRecruit();
    this.bind_toggle_text();
  }

  componentWillUnmount() {
    this.props.actions.clearCampaign();
  }

  _fetchRecruit() {
    const compaign_id = this.props.params.id;
    const { fetchRecruit } = this.props.actions;

    fetchRecruit(compaign_id);
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

  render_result_view() {
    const campaign = this.props.campaign;

    if (campaign.get("recruit_status") === "settling") {
      return (
        <ResultView {...{campaign}}/>
      );
    }
  }

  render_state_text(campaign, campaign_id, actions) {
    if (campaign.get("status") === "executing") {
      return (
        <StateText {...{campaign, campaign_id, actions}} />
      );
    }
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
    const { campaign, actions, campaign_invites, hasfetchedInvite, paginate } = this.props;
    const campaign_id = _.toInteger(this.props.params.id);
    const status = campaign.get("recruit_status");

    return (
      <div className="page page-recruit page-recruit-show">
        <div className="container">
          <BreadCrumb />
          <Basic {...{campaign}} />
          <ShowMaterialsPartial {...{campaign}} />
          <Targets {...{campaign}} />
          <Overview {...{campaign}} />
          { this.render_result_view() }
          { this.render_state_text(campaign, campaign_id, actions) }
          <KolList {...{campaign, status, actions, campaign_invites, campaign_id, hasfetchedInvite, paginate}} />
          { this.renderRevokeBtn() }
          <Evaluation {...{campaign, actions, campaign_id}}  />
        </div>
        <RevokeConfirmModal show={this.state.showRevokeConfirmModal} onHide={this.closeRevokeConfirmModal.bind(this)} actions={this.props.actions} campaignId={campaign.get("id")} />
      </div>
    );
  }
}

export default connect(select)(ShowRecruitCampaignPartial)
