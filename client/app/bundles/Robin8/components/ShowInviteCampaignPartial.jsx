import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash';
import moment from 'moment';

import "campaign/invite/show.scss";

import BreadCrumb  from './shared/BreadCrumb';
import Basic       from './invite_campaigns/show/Basic';
import ShowMaterialsPartial  from './shared/campaign_material/ShowMaterialsPartial'
import Overview    from './invite_campaigns/show/Overview';
import KolList      from './invite_campaigns/show/KolList';
import RevokeConfirmModal       from './campaigns/modals/RevokeConfirmModal';

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

function select(state){
  return {
    campaign: state.campaignReducer.get('campaign'),
    paginate: state.campaignReducer.get("paginate"),
    agreed_invites_of_invite_campaign: state.campaignReducer.get("agreed_invites_of_invite_campaign")
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
    const { campaign, actions, paginate, agreed_invites_of_invite_campaign } = this.props;
    const campaign_id = _.toInteger(this.props.params.id);
    const status = campaign.get("recruit_status");

    return (
      <div className="page page-invite page-invite-show">
        <div className="container">
          <BreadCrumb />
          <Basic {...{campaign}} />
          <ShowMaterialsPartial {...{campaign}} />
          <Overview {...{campaign}} />
          <KolList {...{ actions, campaign_id, agreed_invites_of_invite_campaign }} />
          { this.renderRevokeBtn() }
          <Evaluation {...{campaign, actions, campaign_id}}  />
        </div>
        <RevokeConfirmModal show={this.state.showRevokeConfirmModal} onHide={this.closeRevokeConfirmModal.bind(this)} actions={this.props.actions} campaignId={campaign.get("id")} />
      </div>
    );
  }
}

export default connect(select)(ShowRecruitCampaignPartial)
