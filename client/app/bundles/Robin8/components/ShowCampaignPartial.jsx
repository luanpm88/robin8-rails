import React, { Component } from 'react';
import { Link } from 'react-router';
import moment from 'moment';
import { connect } from 'react-redux';

import "campaign/activity/show.scss";

import Basic from './campaign_show/Basic';
import Overview from './campaign_show/Overview';
import Target from './campaign_show/Target';
import KolList from './campaign_show/KolList';
import Influnce from './campaign_show/Influnce'

function select(state){
  return {
    campaign_invites: state.$$brandStore.get("campaign_invites"),
    hasfetchedInvite: state.$$brandStore.get("hasfetchedInvite"),
    paginate: state.$$brandStore.get("paginate"),
    campaign_statistics: state.$$brandStore.get("campaign_statistics")
  };
}

class ShowCampaignPartial extends Component {
  componentDidMount() {
    console.log("---------campaign show did mount--------");
    this._fetchCampaign();
    this.bind_toggle_text();
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

  render_breadcrumb() {
    return (
      <ol className="breadcrumb">
        <li>
          <i className="caret-arrow left" />
          <Link to="/brand/">我的主页</Link>
        </li>
      </ol>
    );
  }

  render() {
    const campaign = this.props.data.get('campaign');
    const { actions, campaign_invites, hasfetchedInvite, paginate, campaign_statistics} = this.props;
    const campaign_id = this.props.params.id
    return (
      <div className="page page-activity page-activity-show">
        <div className="container">
          { this.render_breadcrumb() }
          <Basic {...{campaign}} />
          <Overview {...{campaign}} />
          <KolList {...{campaign, actions, campaign_invites, campaign_id, hasfetchedInvite, paginate}} />
          <Influnce {...{campaign, actions, campaign_id, campaign_statistics}} />
        </div>
      </div>
    );
  }
}

export default connect(select)(ShowCampaignPartial)
