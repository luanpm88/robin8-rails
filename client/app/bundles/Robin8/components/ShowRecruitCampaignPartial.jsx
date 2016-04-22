import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash';
import moment from 'moment';


import "recruit_activity_detail.scss";

import Basic from './recruit_campaign_show/Basic';
import Overview from './recruit_campaign_show/Overview';
import ResultView from './recruit_campaign_show/ResultView';
import KolList from './recruit_campaign_show/KolList';
import StateText from './recruit_campaign_show/StateText';

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

  getStatus() {
    const campaign = this.props.data.get('campaign'),
      campaign_status = campaign.get("status");

    if (campaign_status === "executing") {
      const end_time = campaign.get("recruit_end_time"),
        has_submit = campaign.get("is_recruit_submited");

      if (has_submit) {
        // offline activity executing
        return "running";
      } else if (moment() > moment(end_time)) {
        // wait for selecting kols
        return "choosing"
      } else {
        // recruiting kols
        return "inviting";
      }
    } else if (campaign_status === "finished") {
      // offline activity finished
      return "finished"
    }
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

  render_result_view(status) {
    const campaign = this.props.data.get('campaign');

    if (status === "finished") {
      return (
        <ResultView {...{campaign}}/>
      );
    }
  }

  render() {
    const campaign = this.props.data.get('campaign');
    const { actions, campaign_invites, hasfetchedInvite, paginate, campaign_statistics} = this.props;
    const campaign_id = _.toInteger(this.props.params.id);
    // const status = this.getStatus();
    const status = "finished";

    console.log(status);

    return (
      <div className="wrapper">
        <div className="container">
          { this.render_breadcrumb() }
          <Basic {...{campaign, status}} />
          <Overview {...{campaign}} />
          { this.render_result_view(status) }
          <StateText {...{campaign, status}} />
          <KolList {...{campaign, status, actions, campaign_invites, campaign_id, hasfetchedInvite, paginate}} />
        </div>
      </div>
    );
  }
}

export default connect(select)(ShowRecruitCampaignPartial)
