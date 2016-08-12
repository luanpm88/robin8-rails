import React from 'react';
import  _ from 'lodash';

import KolScoreModal  from '../../recruit_campaigns/modals/KolScoreModal';
import KolScoreInfoModal from '../../recruit_campaigns/modals/KolScoreInfoModal';

export default class KolList extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      showKolScoreModal: false,
      showKolScoreInfoModal: false
    };

    _.bindAll(this, [
      "renderKolItem",
      "fetchTotalAgreedInvites"
    ])
  }

  closeShowKolScoreModal() {
    this.setState({showKolScoreModal: false});
  }

  closeShowKolScoreInfoModal() {
    this.setState({showKolScoreInfoModal: false});
  }

  show_kol_score_modal() {
    this.setState({showKolScoreModal: true})
  }

  show_score_info_modal() {
    this.setState({showKolScoreInfoModal: true})
  }

  componentDidMount() {
    this.fetchTotalAgreedInvites();
  }

  fetchTotalAgreedInvites() {
    const { fetchAgreedInvitesOfInviteCampaign } = this.props.actions;
    fetchAgreedInvitesOfInviteCampaign(this.props.campaign_id)
  }

  renderScreeshot(invite) {
    if(invite.screenshot) {
      return <td>{invite.screenshot}</td>
    } else {
      return <td>未上传截图</td>
    }
  }

  renderScoreMarkButton(invite) {
    if (invite.get("kol_score")) {
      return <td><button className="btn btn-blue btn-default show-score-mark-btn" onClick={this.show_score_info_modal.bind(this)}>查看评分</button></td>
    }
    return <td><button className="btn btn-blue btn-default score-mark-btn" onClick={this.show_kol_score_modal.bind(this)}>评分</button></td>
  }

  renderKolItem(invite, state="active") {
    const kol = invite.get("kol");
    let item;
    let index = 0;
    kol.get("social_accounts").forEach(function(account) {
      if(account.get("id") == invite.get("social_account_id")) {
        item =
          <tr className={`kol-item ${state}`} data-id={account.get("id")} key={ `kol-${account.get("id")}` }>
            <td>
              <div className="avatar">
                <img src={account.get("avatar_url")} />
                {account.get("username")}
              </div>
            </td>
            <td>{account.get("provider_text")}</td>
            <td>{account.get("sale_price")}元/条</td>
            <td>{account.get("tags").map(i => i.get("label")).join("/")}</td>
            {this.renderScreeshot(invite)}
            {this.renderScoreMarkButton(invite)}
            <KolScoreModal show={this.state.showKolScoreModal} onHide={this.closeShowKolScoreModal.bind(this)} index={index++} isInviteCampaign={true} actions={this.props.actions} campaignInvite={invite} />
            <KolScoreInfoModal show={this.state.showKolScoreInfoModal} onHide={this.closeShowKolScoreInfoModal.bind(this)} campaignInvite={invite}  />
          </tr>

      }
    }.bind(this))
    return item;
  }

  renderKolList(list) {
    return (
      <table>
        <colgroup width="160"></colgroup>
        <colgroup width="60"> ></colgroup>
        <colgroup width="80"> ></colgroup>
        <colgroup width="100"></colgroup>
        <colgroup width="80"></colgroup>
        <colgroup width="80"></colgroup>
        <thead>
          <tr>
            <th>报名列表</th>
            <th>平台</th>
            <th>报价</th>
            <th>分类</th>
            <th>截图</th>
            <th>评分</th>
          </tr>
        </thead>
        <tbody className="kol-list">
          { list }
        </tbody>
      </table>
    );
  }

  renderSelectedKols() {
    const agreed_invites_of_invite_campaign = this.props.agreed_invites_of_invite_campaign;
    if(agreed_invites_of_invite_campaign.size) {
      let selectedKolsList = [],
      selectedKolsAlert,
      selectedKolsResult;
      agreed_invites_of_invite_campaign.map((invite, index) => {
        const item = this.renderKolItem(invite, "selected");
        selectedKolsList.push(item);
      });

      selectedKolsResult = this.renderKolList(selectedKolsList)
      if (selectedKolsList.length == 0) {
        selectedKolsAlert =
        <div className="kol-list-empty">
          还没有KOL接受邀请
        </div>
      }

      return (
        <div className="creat-activity-form select-list-form">
          <div className="content">
            <div className="kol-list-wrap">
              { selectedKolsResult }
              { selectedKolsAlert }
            </div>
          </div>
        </div>
      );
    }
  }

  render() {
    return (
      <div className="kol-selector panel activity-stat-bigshow-panel">
        <div className="kol-selected-list-wrap">
          { this.renderSelectedKols() }
        </div>
      </div>
    );
  }
}
