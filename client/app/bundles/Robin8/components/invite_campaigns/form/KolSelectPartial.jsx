import React from 'react';
import  _ from 'lodash';

import TargetPartial        from './TargetPartial';
import SocialAccountDetailModal       from '../modals/SocialAccountDetailModal';

const baseUrl = "/brand_api/v1"

export default class KolSelectPartial extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      showSocialAccountDetailModal: false,
      showSocialAccountId: null,
      selectedSocialAccounts: [],
      searchedSocialAccounts: [],
      searchedSocialAccountPaginate: {}
    };

    this.searchCondition = {};

    _.bindAll(this, [
      "renderPaginator",
      "renderKolItem",
      "handleConditionChange",
      "handleSearchKolsInCondition",
      "handleAddSocialAccount", "handleRemoveSocialAccount"
    ])
  }

  componentDidMount() {
  }

  componentDidUpdate() {
    this.renderPaginator();
  }

  componentWillReceiveProps(nextProps) {
    if (!this.props.selected_social_accounts &&
        !!nextProps.selected_social_accounts) {
      this.setState({
        selectedSocialAccounts: nextProps.selected_social_accounts.toJS()
      });
    }
  }

  handleSearchKolsInCondition(page = 1) {
    let params = [ `page=${page}` ];
    _.forIn(this.searchCondition, (value, key) => params.push(`${key}=${value}`));

    const queryString = params.join("&");
    fetch(`${baseUrl}/social_accounts/search?${queryString}`, {"credentials": "include"})
      .then(response => response.json())
      .then(data => {
        this.setState({
          searchedSocialAccounts: data.items,
          searchedSocialAccountPaginate: data.paginate
        })
      });
  }

  handleConditionChange(condition = {}) {
    this.searchCondition = condition;
    this.handleSearchKolsInCondition();
  }

  handleAddSocialAccount(event) {
    const { budget, social_accounts } = this.props;
    const item = event.currentTarget;
    const id = $(item).closest(".kol-item").data("id");

    if (social_accounts.value.length > 0) {
      alert("抱歉，目前只支持选择一位KOL");
      return;
    }

    if (!social_accounts.value.includes(id)) {
      let { selectedSocialAccounts } = this.state;
      const kol = _.find(this.state.searchedSocialAccounts, {"id": id});

      budget.onChange(budget.value + kol.sale_price);
      social_accounts.value.push(id);
      selectedSocialAccounts.push(kol);

      this.setState({ selectedSocialAccounts });
    }
  }

  handleRemoveSocialAccount(event) {
    const { budget, social_accounts } = this.props;
    const item = event.currentTarget;
    const id = $(item).closest(".kol-item").data("id");

    if (social_accounts.value.includes(id)) {
      let { selectedSocialAccounts } = this.state;
      const kol = _.find(selectedSocialAccounts, {'id': id});

      budget.onChange(budget.value - kol.sale_price);
      _.remove(social_accounts.value, n => {return n == id});
      _.remove(selectedSocialAccounts, k => {return k.id == id});

      this.setState({ selectedSocialAccounts });
    }
  }

  closeSocialAccountDetailModal() {
    this.setState({
      showSocialAccountDetailModal: false,
      showSocialAccountId: null
    });
  }

  renderSocialAccountDetailModal(socialAccountId) {
    this.setState({
      showSocialAccountDetailModal: true,
      showSocialAccountId: socialAccountId
    });
  }

  renderTips(){
    const tips = "<p>&nbsp;根据条件搜索KOL并挑选合适的加入到此列表</p>"
    return tips;
  }

  renderPaginator() {
    const paginate = this.state.searchedSocialAccountPaginate;

    if (paginate["X-Page"] && paginate["X-Total-Pages"]) {
      const pagination_options = {
        currentPage: paginate["X-Page"],
        totalPages: paginate["X-Total-Pages"],
        onPageClicked: (e,originalEvent,type,page) => {
          this.handleSearchKolsInCondition(page);
        }
      }
      $("#searched_kols_paginator").bootstrapPaginator(pagination_options);
    }
  }

  renderKolItem(kol, state="active") {
    let actionBtn;

    switch(state) {
      case "active":
        actionBtn = (
          <div className="btn btn-line btn-red add"
            onClick={ this.handleAddSocialAccount } >
            邀请
          </div>
        );
        break;
      case "selected":
        actionBtn = (
          <div className="btn btn-line btn-red remove"
            onClick={ this.handleRemoveSocialAccount } >
            取消
          </div>
        );
        break;
      case "disabled":
        actionBtn = (
          <div className="btn btn-line btn-default">
            已邀请
          </div>
        );
        break;
      default:
        break;
    }

    return(
      <tr className={`kol-item ${state}`} data-id={kol.id} key={ `kol-${kol.id}` }>
        <td>
          <div className="avatar">
            <img src={kol.avatar_url} />
            {kol.username}
          </div>
        </td>
        <td>{kol.provider_text}</td>
        <td>{ kol.sale_price > 0 ? `${kol.sale_price}元/条` : "待询价"}</td>
        <td>{kol.tags.map(i => i.label).join("/")}</td>
        <td>
          { actionBtn }
          <div className="arrow-right show-detail"
               onClick={event => this.renderSocialAccountDetailModal(kol.id)}>
          </div>
        </td>
      </tr>
    );
  }

  renderKolList(list) {
    return (
      <table>
        <colgroup width="200"></colgroup>
        <colgroup width="180"></colgroup>
        <colgroup width="180"></colgroup>
        <colgroup width="180"></colgroup>
        <colgroup width="180"></colgroup>
        <thead>
          <tr>
            <th>报名列表</th>
            <th>平台</th>
            <th>报价</th>
            <th>分类</th>
            <th>邀请</th>
          </tr>
        </thead>
        <tbody className="kol-list">
          { list }
        </tbody>
      </table>
    );
  }

  renderSelectedKols() {
    const { budget } = this.props;
    let selectedKolsList = [],
        selectedKolsAlert,
        selectedKolsResult;

    _.forEach(this.state.selectedSocialAccounts, (kol) => {
      const item = this.renderKolItem(kol, "selected");
      selectedKolsList.push(item);
    });

    selectedKolsResult = this.renderKolList(selectedKolsList)
    if (selectedKolsList.length == 0) {
      selectedKolsAlert =
        <div className="kol-list-empty">
          还没有选中KOL
        </div>
    }

    return (
      <div className="creat-activity-form select-list-form">
        <div className="header">
          <h3 className="tit">已选KOL列表&nbsp;<span className="what" data-toggle="tooltip" title={this.renderTips()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="notice">活动预算 <em>{`${budget.value} 元`}</em></div>
          <div className="kol-list-wrap">
            { selectedKolsResult }
            { selectedKolsAlert }
          </div>
        </div>
      </div>
    );
  }

  renderSearchedKols() {
    let searchedKolsList = [],
        searchedKolsAlert,
        searchedKolsResult,
        searchedkolsPaginator;

    _.forEach(this.state.searchedSocialAccounts, (kol) => {
      let item;
      if (!_.find(this.state.selectedSocialAccounts, {"id": kol.id})) {
        item = this.renderKolItem(kol);
      } else {
        item = this.renderKolItem(kol, "disabled");
      }
      searchedKolsList.push(item);
    });

    searchedKolsResult = this.renderKolList(searchedKolsList)

    if (searchedKolsList.length > 0) {
      searchedkolsPaginator =
        <div id="searched_kols_paginator"></div>
    } else {
      searchedKolsAlert =
        <div className="kol-list-empty">
          没有符合条件的KOL
        </div>
    }

    return (
      <div className="creat-activity-form search-list-form">
        <div className="content">
          <h3>搜索结果</h3>
          <div className="kol-list-wrap">
            { searchedKolsResult }
            { searchedkolsPaginator }
            { searchedKolsAlert }
          </div>
        </div>
      </div>
    );
  }

  render() {
    return (
      <div className="kol-selector">
        <div className="kol-selected-list-wrap">
          { this.renderSelectedKols() }
        </div>
        <div className="kol-search-wrap">
          <TargetPartial onChange={event => { this.handleConditionChange(event) }} />
        </div>
        <div className="kol-search-list-wrap">
          { this.renderSearchedKols() }
        </div>
        <SocialAccountDetailModal
          socialAccountId={this.state.showSocialAccountId}
          show={this.state.showSocialAccountDetailModal}
          onHide={this.closeSocialAccountDetailModal.bind(this)}/>
      </div>
    );
  }
}

