import React from 'react';
import {ShowError} from '../shared/ShowError';

export default class DetailPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchShortUrl', '_initTouchSpin', '_handlePerBudgetInputChange', '_listenPerBudgetTypeChange']);
  }


  _fetchShortUrl(e) {
    e.preventDefault();

    const { action_url, short_url, action_url_identifier } = this.props;

    if(action_url.error) {
      action_url.onBlur();
      return;
    }

    if(action_url.value == $(".action-url").attr("data-origin-url") && $(".action_url_identifier").val() != "") return;
    const brand_id = this.props.brand.get('id').toString();
    const timestamps = Math.floor(Date.now()).toString();
    const random = Math.floor(Math.random() * 100000).toString();
    const identifier = brand_id + timestamps + random;

    fetch( `/brand_api/v1/campaigns/short_url?url=${action_url.value}&identifier=${identifier}`, { credentials: 'same-origin' })
      .then(function(response) {
        response.json().then(function(data){
          short_url.onChange(data);
          action_url_identifier.onChange(identifier);
          $(".action-url").attr("data-origin-url", action_url.value);
        })
      },
      function(error){
        console.log("-----fetchShortUrl error");
      })
  }

  _initTouchSpin() {
    $('.per-budget-input').TouchSpin({
      min: 0.1,
      max: 10000000,
      prefix: '￥',
      step: 0.1,
      decimals: 1,
    })
  }

  _handlePerBudgetInputChange() {
    const { onChange } = this.props.per_action_budget;
    $('.per-budget-input').change(function() {
      onChange($(this).val());
    })
  }

  _listenPerBudgetTypeChange() {
    const { per_action_budget } = this.props;
    $("input[name='action_type']").change(function(){
      per_action_budget.onBlur();
    })
  }

  componentDidMount() {
    this._initTouchSpin();
    this._handlePerBudgetInputChange();
    this._listenPerBudgetTypeChange();
  }

  componentWillUnmount() {
    $('.spinner-input').off('change');
  }

  renderDetailTips(){
    const tip = "1、按照发布奖励KOL: 只要分享即可获得奖励。\n2、按照点击奖励KOL: 要求被分享出去的活动必须有朋友点击才可获得奖励, 最后按该次分享被点击的次数结算。\n3、按照行动奖励KOL: KOL必须完成指定的操作流程才可获得奖励，例如点击长文中的某个链接等等。"
    return tip
  }

  render() {
    const { per_budget_type, action_url, action_url_identifier, short_url, per_action_budget } = this.props
    return (
      <div className="creat-activity-form creat-content-sources">
        <div className="header">
          <h3 className="tit">推广详情&nbsp;<span className="what" title={this.renderDetailTips()}>?</span></h3>
        </div>
        <div className="content">
          <div className="form-item form-horizontal">
            <p className="action-mode">
              奖励模式选择
            </p>
            <div className="sources-check radio">
              <label>
                <input {...per_budget_type} type="radio" name="action_type" value="post" onChange={per_budget_type.onChange} checked={per_budget_type.value === "post"} />
                按照发布奖励KOL
              </label>
              <label>
                <input {...per_budget_type} type="radio" name="action_type" value="click" onChange={per_budget_type.onChange} checked={per_budget_type.value === "click"} />
                按照点击奖励KOL
              </label>
              <label>
                <input {...per_budget_type} type="radio" name="action_type" value="cpa" onChange={per_budget_type.onChange} checked={per_budget_type.value === "cpa"} />
                按照行动奖励KOL
              </label>
            </div>

            <div className="action-url-group" style={ (per_budget_type && per_budget_type.value == 'cpa') ? {display: 'block'} : {display: 'none'} }>
              <div className="clearfix">
                <p className="action-url-text">确认链接</p>
                <div className="action-url-section">
                  <input {...action_url} type="text" data-origin-url={action_url.defaultValue} className="form-control action-url" placeholder="请填写确认页的URL方便追踪行动是否完成"></input>
                  <ShowError field={action_url} />
                </div>
              </div>
              <div className="clearfix">
                <button className="btn btn-blue btn-default generate-short-url-btn" onClick={this._fetchShortUrl}>生成链接</button>
              </div>
              <div className="clearfix">
                <p className="generate-short-url-text">生成链接</p>
                <div className="action-short-url_section">
                  <input {...short_url} type="text" className="action-short-url" disabled="disabled" readOnly></input>
                  <ShowError field={short_url} />
                  <p className="action-url-notice">请将下载按钮的href或下载完成页的href替换成生成的链接以方便追踪</p>
                </div>
                <input {...action_url_identifier} type="hidden" disabled="disabled" className="action_url_identifier" readOnly></input>
              </div>
            </div>

            <div className="per-budget-group">
              <p className="per-budget-text">单次预算</p>
              <div className="spinner-form-area">
                <div className="spinner-box per_action_budget-input">
                  <span className="symbol">$</span>
                  <input {...per_action_budget} type="text" className="clearfix spinner-input per-budget-input " style={{display: 'block'}} />
                  <div className="per-budget-input-error">
                    <ShowError field={per_action_budget} optionStyle={"padding-left: 45px"}/>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    )
  }
}
