import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash';
import moment from 'moment';

import "campaign/recruit/show.scss";

import BreadCrumb  from './shared/BreadCrumb';
import Basic       from './recruit_campaigns/show/Basic';
import Overview    from './recruit_campaigns/show/Overview';
import ResultView  from './recruit_campaigns/show/ResultView';
import KolList     from './recruit_campaigns/show/KolList';
import StateText   from './recruit_campaigns/show/StateText';

function select(state){
  return {
    campaign: state.campaignReducer.get('campaign'),
    campaign_invites: state.campaignReducer.get("campaign_invites"),
    hasfetchedInvite: state.campaignReducer.get("hasfetchedInvite"),
    paginate: state.campaignReducer.get("paginate"),
  };
}

class ShowRecruitCampaignPartial extends Component {
  componentDidMount() {
    this._fetchRecruit();
    this.bind_toggle_text();
    console.log("---------recruit campaign show did mount--------");
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

  render() {
    const { campaign, actions, campaign_invites, hasfetchedInvite, paginate } = this.props;
    const campaign_id = _.toInteger(this.props.params.id);
    const status = campaign.get("recruit_status");

    return (
      <div className="page page-recruit page-recruit-show">
        <div className="container">
          <BreadCrumb />
          <Basic {...{campaign}} />
          <Overview {...{campaign}} />
          { this.render_result_view() }
          { this.render_state_text(campaign, campaign_id, actions) }
          <KolList {...{campaign, status, actions, campaign_invites, campaign_id, hasfetchedInvite, paginate}} />
        </div>
      </div>
    );
  }
}

export default connect(select)(ShowRecruitCampaignPartial)
