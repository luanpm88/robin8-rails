import React, { Component } from 'react';
import { Link } from 'react-router';
import moment from 'moment';
import { connect } from 'react-redux';

import "recruit_activity_detail.scss";

import Basic from './recruit_campaign_show/Basic';
import Overview from './recruit_campaign_show/Overview';
import KolList from './recruit_campaign_show/KolList';
import Counter from './recruit_campaign_show/Counter';

function select(state){
  return {
    campaign_invites: state.$$brandStore.get("campaign_invites"),
    hasfetchedInvite: state.$$brandStore.get("hasfetchedInvite"),
    paginate: state.$$brandStore.get("paginate"),
    campaign_statistics: state.$$brandStore.get("campaign_statistics")
  };
}

export default class ShowRecruitCampaignPartial extends Component {
  componentDidMount() {
    console.log("---------recruit campaign show did mount--------");
    this._fetchRecruitCampaign();
    this.bind_toggle_text();
  }

  _fetchRecruitCampaign() {
    const recruit_compaign_id = this.props.params.id;
    const { fetchRecruitCampaign } = this.props.actions;

    // can load campaign from campaigns
    // const campaigns = this.props.data.get("campaigns");

    fetchRecruitCampaign(recruit_compaign_id);
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
    const campaign_id = this.props.params.id;
    return (
      <div className="wrapper">
        <div className="container">
          { this.render_breadcrumb() }
          <Basic {...{campaign}} />
          <Overview {...{campaign}} />
          <Counter {...{campaign}} />
          <KolList {...{campaign, actions, campaign_invites, campaign_id, hasfetchedInvite, paginate}} />
          <div className="bottom-tips">*请在报名截止后确定招募名单</div>
        </div>
      </div>
    );
  }
}

export default connect(select)(ShowRecruitCampaignPartial)
