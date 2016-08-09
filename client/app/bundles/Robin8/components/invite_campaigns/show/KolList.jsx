import React from 'react';
import  _ from 'lodash';

export default class KolSelectPartial extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.searchCondition = {};
    this.total_agreed_invites = [];

    _.bindAll(this, [
      "renderKolItem",
      "fetchAgreedInvites"
    ])
  }

  componentDidMount() {
    this.fetchAgreedInvites();
  }

  fetchAgreedInvites() {
    const campaign_id = this.props.campaign_id;
    fetch(`/brand_api/v1/invite_campaigns/${campaign_id}/agreed_invites`, {"credentials": "include"})
      .then(function(response) {
        response.json().then(function(data){
          this.total_agreed_invites = data.items;
      }.bind(this))
    }.bind(this),
    function(error) {
      console.error("----------获取已接受邀请invites失败---------------");
    })
  }
  
  renderScreeshot(invite) {
    debugger
    if(invite.screenshot) {
      return <td>{invite.screenshot}</td>
    } else {
      return <td>未上传截图</td>
    }
  }

  renderKolItem(invite, state="active") {
    const kol = invite.kol;
    let item;
    kol.social_accounts.forEach(function(account) {
      if(account.id == invite.social_account_id) {
        item =
          <tr className={`kol-item ${state}`} data-id={account.id} key={ `kol-${account.id}` }>
            <td>
              <div className="avatar">
                <img src={account.avatar_url} />
                {account.username}
              </div>
            </td>
            <td>{account.provider_text}</td>
            <td>{account.sale_price}元/条</td>
            <td>{account.tags.map(i => i.get("label")).join("/")}</td>
            {this.renderScreeshot(invite)}
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
    if(this.props.campaign.size) {
      let selectedKolsList = [],
      selectedKolsAlert,
      selectedKolsResult;

      this.total_agreed_invites.map((invite, index) => {
        const item = this.renderKolItem(invite, "selected");
        debugger
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
