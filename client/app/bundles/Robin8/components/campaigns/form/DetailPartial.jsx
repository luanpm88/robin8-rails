import React from 'react';
import {ShowError} from '../../shared/ShowError';

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
      min: 0.2,
      max: 10000000,
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
    $("input[name='action_type']").change(function(){
      const { per_action_budget, per_budget_type, per_budget_collect_type } = this.props;
      if(per_budget_type.value == 'post') {
        per_action_budget.onChange("2.0")
      }
      if(per_budget_type.value == 'click') {
        per_action_budget.onChange("0.2")
      }
      per_action_budget.onFocus();
      per_action_budget.onBlur();

      // console.log("变化后的 %s")
      // console.log(per_budget_type.value)
      // if(per_budget_type.value == "post" || per_budget_type.value == "click"){
      //   per_budget_collect_type.onChange('');
      // }else{
      //   per_budget_collect_type.onChange('cpa_cpi');
      // }
    }.bind(this))


    $("input[name='cap_cpi-collect-action_type']").click(function(){
      const { per_action_budget, per_budget_type, per_budget_collect_type } = this.props;
      if(per_budget_type.value == "post" || per_budget_type.value == "click"){
        per_budget_type.onChange("cpa");
      }
    }.bind(this))

    $(".commonPerBudgetType").click(function(){
      // 修改safari 下面的不兼容情况
      const { per_budget_collect_type } = this.props;
      per_budget_collect_type.onChange('');
    }.bind(this))
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
    const tip = "<p>1.&nbsp;按照转发奖励KOL: 按照KOL转发一次性付费。\
                 <p>2.&nbsp;按照点击奖励KOL: KOL分享后按照好友有效点击数付费。\
                 <p>2.&nbsp;按照活动效果奖励KOL: KOL分享后按照活动效果付费。\
                 "
                 //<p>3.&nbsp;按照行动奖励KOL: KOL必须完成指定的操作流程才可获得奖励，例如点击长文中的某个链接等等。
    return tip
  }

  render() {
    const { per_budget_type, per_budget_collect_type, action_url, action_url_identifier, short_url, per_action_budget} = this.props

    return (
      <div className="creat-activity-form creat-content-sources">
        <div className="header">
          <h3 className="tit">推广详情&nbsp;<span className="what" data-toggle="tooltip" title={this.renderDetailTips()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="form-item form-horizontal">
            <p className="action-mode">
              奖励模式选择
            </p>
            <div className="sources-check radio">
              <label>
                <input {...per_budget_type} type="radio" name="action_type" value="click" className="commonPerBudgetType"  onChange={per_budget_type.onChange} checked={per_budget_type.value === "click"} />
                按照点击奖励KOL
              </label>
              <label>
                <input {...per_budget_type} type="radio" name="action_type" className="commonPerBudgetType" value="post" onChange={per_budget_type.onChange} checked={per_budget_type.value === "post"} />
                按照转发奖励KOL
              </label>
              {
                do{
                <label>
                  <input {...per_budget_collect_type} type="radio" className="cap_cpi-collect-action_type" name="cap_cpi-collect-action_type" value="cpa_cpi" onChange={per_budget_collect_type.onChange} checked={(per_budget_type.value === "cpa" || per_budget_type.value === "cpi" || per_budget_collect_type.value === "cpa_cpi")} />
                  按照活动效果奖励KOL
                </label>
              }
            }
            </div>

            <div className="action-url-group" style={ (per_budget_collect_type.value == "cpa_cpi" || (per_budget_type && (per_budget_type.value == 'cpi' || per_budget_type.value == 'cpa'))) ? {display: 'block'} : {display: 'none'} }>
              <div className="cpa-cpi-select-img">
                <img src={require("cpa-cpi-background.png")} />
              </div>
              <div className="sources-check cpa-cpi-select radio">
                <label>
                    <input {...per_budget_type} type="radio" name="action_type" value="cpa" onChange={per_budget_type.onChange} checked={per_budget_type.value === "cpa"} />
                  按链接点击次数付费(仅支持链接类型)
                </label>
                <label>
                    <input {...per_budget_type} type="radio" name="action_type" value="cpi" onChange={per_budget_type.onChange} checked={per_budget_type.value === "cpi"} />
                  按下载次数付费(用于APP推广)
                </label>
              </div>
              {
                do {
                  if(per_budget_type.value == "cpa"){
                    <div>
                      <div className="action-url-area clearfix">
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
                  }else{
                    <div className="cpi-tip-label">
                      <label>活动支付成功后, 我们的工作人员会联系您安装相关SDK</label>
                    </div>
                  }
                }
              }
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
                  <div className="price-tip">
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'post') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次转发的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'click') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次点击的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'cpa') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次点击的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'cpi') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次下载的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
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
