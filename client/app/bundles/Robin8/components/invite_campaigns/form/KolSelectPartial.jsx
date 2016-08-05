import React from 'react';
import  _ from 'lodash';

import TargetPartial      from './TargetPartial';

export default class KolSelectPartial extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.searchCondition = {};

    _.bindAll(this, [
      "renderPaginator",
      "renderKolItem",
      "handleConditionChange",
      "handleSearchKolsInCondition",
      "handleAddKol", "handleRemoveKol"
    ])
  }

  componentDidMount() {
  }

  componentDidUpdate() {
    this.renderPaginator();
  }

  handleSearchKolsInCondition(page = 1) {
    const { actions } = this.props;
    actions.searchKolsInCondition(this.searchCondition, page);
  }

  handleConditionChange(condition = {}) {
    this.searchCondition = condition;
    this.handleSearchKolsInCondition();
  }

  handleAddKol(event) {
    const { actions, budget, searched_social_accounts, social_accounts } = this.props;
    const item = event.currentTarget;
    const id = $(item).closest(".kol-item").data("id");

    if (!social_accounts.value.includes(id)) {
      const kol = searched_social_accounts.get("items").find((k) => {
        return k.get("id") == id;
      });

      social_accounts.value.push(id);
      budget.onChange(budget.value + kol.get("sale_price"));
      actions.addSelectedKol(kol);
    }
  }

  handleRemoveKol(event) {
    const { actions, budget, selected_social_accounts, social_accounts } = this.props;
    const item = event.currentTarget;
    const id = $(item).closest(".kol-item").data("id");

    if (social_accounts.value.includes(id)) {
      const kol = selected_social_accounts.find((k) => {
        return k.get("id") == id;
      });

      _.remove(social_accounts.value, (n) => {
        return n == id;
      });
      budget.onChange(budget.value - kol.get("sale_price"));
      actions.removeSelectedKol(kol);
    }
  }

  renderTips(){
    const tips = "<p>&nbsp;根据条件搜索KOL并挑选合适的加入到此列表</p>"
    return tips;
  }

  renderPaginator() {
    const { searched_social_accounts } = this.props;
    const paginate = searched_social_accounts.get("paginate");

    if (paginate.get("X-Page") && paginate.get("X-Total-Pages")) {
      const pagination_options = {
        currentPage: paginate.get("X-Page"),
        totalPages: paginate.get("X-Total-Pages"),
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
            onClick={ this.handleAddKol } >
            邀请
          </div>
        );
        break;
      case "selected":
        actionBtn = (
          <div className="btn btn-line btn-red remove"
            onClick={ this.handleRemoveKol } >
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
      <tr className={`kol-item ${state}`} data-id={kol.get("id")} key={ `kol-${kol.get("id")}` }>
        <td>
          <div className="avatar">
            <img src={kol.get("avatar_url")} />
            {kol.get("username")}
          </div>
        </td>
        <td>{kol.get("provider_text")}</td>
        <td>{kol.get("sale_price")}/条</td>
        <td>{kol.get("tags").map(i => i.get("label")).join("/")}</td>
        <td>
          { actionBtn }
          <div className="arrow-right show-detail"></div>
        </td>
      </tr>
    );
  }

  renderKolList(list) {
    return (
      <table>
        <colgroup width="200"></colgroup>
        <colgroup width="180"> ></colgroup>
        <colgroup width="180"> ></colgroup>
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
    const { selected_social_accounts, budget } = this.props;
    let selectedKolsList = [],
        selectedKolsAlert,
        selectedKolsResult;

    selected_social_accounts.map((kol, index) => {
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
          <div className="notice">活动预算 <em>{budget.value} 元</em></div>
          <div className="kol-list-wrap">
            { selectedKolsResult }
            { selectedKolsAlert }
          </div>
        </div>
      </div>
    );
  }

  renderSearchedKols() {
    const { searched_social_accounts, selected_social_accounts } = this.props;
    let searchedKolsList = [],
        searchedKolsAlert,
        searchedKolsResult,
        searchedkolsPaginator;

    searched_social_accounts.get("items").map((kol, index) => {
      let item;
      if (!selected_social_accounts.find((k) => {return k.get("id") == kol.get("id")})) {
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
      </div>
    );
  }
}

