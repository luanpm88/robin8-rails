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
    const { per_action_budget, per_budget_type, sub_type } = this.props;
    const { onChange } = this.props.per_action_budget;
    $('.per-budget-input').change(function() {
      onChange($(this).val());
      console.log(onChange($(this).val()))
      console.log($('#dianji').prop('checked'))
    });// not working

    // $( ".per-budget-input" ).trigger("touchspin.updatesettings", {min: $('#dianji').prop('checked') ? 3.5 : 4});


  }

  _listenPerBudgetTypeChange() {
    const { per_action_budget, per_budget_type, sub_type } = this.props;

    $("input[name='action_type']").change(function(){
      if(per_budget_type.value == 'post') {
        per_action_budget.onChange("2.0")
      }
      if(per_budget_type.value == 'click') {
        per_action_budget.onChange("0.2") // initial min value is 0.2
        sub_type.onChange("wechat");
      }
      if(per_budget_type.value == 'simple_cpi') {
        per_action_budget.onChange("2.0")
      }
      if(per_budget_type.value == 'cpt') {
        per_action_budget.onChange("1.0")
      }
      if(per_budget_type.value == 'cpa') {
        per_action_budget.onChange("1.0")
      }
      per_action_budget.onFocus();
      per_action_budget.onBlur();
    }.bind(this))

    $(".commonPerBudgetType").click(function(){
      // 修改safari 下面的不兼容情况
      const { per_budget_collect_type } = this.props;
      per_budget_collect_type.onChange('');
    }.bind(this))
  }

  // _checkPerBudgetTypeChange() {
  //   var min = 3;
  //
  //   $("input[name='action_type']").change(function(){
  //     console.log('oops')
  //     min = 3.5;
  //     $( ".per-budget-input" ).trigger("touchspin.updatesettings", {min: min});
  //   });
  // }


  componentDidMount() {
    this._initTouchSpin();
    this._handlePerBudgetInputChange();
    this._listenPerBudgetTypeChange();
    // this._checkPerBudgetTypeChange();
  }

  componentDidUpdate(prevProps, prevState) {
    console.log('v0003');
    //console.log("prevProps are : ", prevProps);
    let oldValue = prevProps.per_budget_type.value;
    console.log("oldValue", oldValue);
    let newValue = this.props.per_budget_type.value;
    console.log("newValue", newValue);
    let min = this.props.per_budget_type.value === 'post' ? 2.5 : 0.2;

    if(oldValue==newValue) return console.log('escape');
    // unable to change min value with this method
    // $('.per-budget-input').TouchSpin({
    //   min: min,
    //   max: 10000000,
    //   step: 0.1,
    //   decimals: 1,
    // })
    // trigger method will cause infinite loop
    // because per_budget_type.value is not fully loaded in the initial rendering
    // its value become valid after the birth phase of the component
    // which then exit the loop
    if(true){
      console.log('calling .trigger');
      $('.per-budget-input').trigger("touchspin.updatesettings", {min: min});
    }

  }

  componentWillUnmount() {
    $('.spinner-input').off('change');
  }

  // componentWillUpdate() {
  //   var asdf = 0;
  //   if(this.props.per_budget_type.value == 'click') {
  //     console.log('click');
  //     asdf = 3;
      // $('.per-budget-input').trigger("touchspin.updatesettings", {min: 2.5});
  //   }
  //   if(this.props.per_budget_type.value == 'post') {
  //     asdf = 3.3;
  //     console.log('post');
  //   }
  //   console.log(asdf)
  // }

  renderDetailTips(){
    const tip = "<p>1.&nbsp;按照转发奖励KOL: 按照KOL转发一次性付费。\
                 <p>2.&nbsp;按照点击奖励KOL: KOL分享后按照好友有效点击数付费。\
                 <p>3.&nbsp;按照活动效果奖励KOL: KOL分享后按照活动效果付费。\
                 "
    return tip
  }

  render() {
    const { per_budget_type, action_url, action_url_identifier, short_url, per_action_budget, sub_type } = this.props
    return (

      <div className="react-toolbox creat-content-sources">
        <div className="header">
          <h3 className="tit" style={{textAlign: "center"}}>推广详情&nbsp;<span className="what" data-toggle="tooltip" title={this.renderDetailTips()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content" style={{backgroundColor: "white"}}>
          <div className="form-item form-horizontal" style={{marginLeft: '3em'}}>
            <div className="row">
              <p className="action-mode">推广平台选择</p>
              <div className="sources-check">
                {
                  do {
                    let enableSharingAll = true;
                    if (enableSharingAll) {
                      <div className="row">
                        <div className="col-md-4">
                          <input {...sub_type} type="radio" name="sub_type" value="wechat" className="formardPlatformType" onChange={sub_type.onChange} checked={sub_type.value === "wechat"} />
                          分享到朋友圈
                        </div>

                        <div className="col-md-4">
                          <input {...sub_type} type="radio" name="sub_type" value="weibo" className="formardPlatformType" onChange={sub_type.onChange} checked={sub_type.value === "weibo"} />
                          分享到微博
                        </div>
                      </div>
                    } else {
                      <div className="row">
                        <div className="col-md-4">
                          <input {...sub_type} type="radio" name="sub_type" value="wechat" className="formardPlatformType"  onChange={sub_type.onChange} checked={sub_type.value === "wechat"} />
                          分享到朋友圈
                        </div>
                      </div>
                    }
                  }
                }
              </div>
            </div>

            <div className="row forward-platform-select">
              <p className="action-mode">奖励模式选择</p>
              <div className="sources-check">
                {
                  do {

                      if(sub_type.value === "wechat") {
                        <div className="row">

                          <div className="col-md-4" style={{marginBottom: '1em'}}>
                            <input {...per_budget_type} type="radio"
                              name="action_type"
                              value="click" className="commonPerBudgetType"
                              id="dianji"
                              onChange={per_budget_type.onChange}
                              checked={per_budget_type.value === "click"} />
                            按照点击奖励KOL
                          </div>

                          <div className="col-md-4" style={{marginBottom: '1em'}}>
                            <input {...per_budget_type} type="radio"
                              name="action_type"
                              value="post" className="commonPerBudgetType"
                              id="zhuanfa"
                              onChange={per_budget_type.onChange}
                              checked={per_budget_type.value === "post"} />
                            按照转发奖励KOL
                          </div>

                          {/* <div className="col-md-4" style={{marginBottom: '1em'}}>
                            <input {...per_budget_type} type="radio" name="action_type" value="simple_cpi" onChange={per_budget_type.onChange} checked={per_budget_type.value === "simple_cpi"} />
                            按照下载APP奖励KOL
                          </div>

                          <div className="col-md-4" style={{marginBottom: '1em'}}>
                            <input {...per_budget_type} type="radio" name="action_type" value="cpa" onChange={per_budget_type.onChange} checked={per_budget_type.value === "cpa"} />
                            按照点击指定链接奖励KOL
                          </div>

                          <div className="col-md-4" style={{marginBottom: '1em'}}>
                            <input {...per_budget_type} type="radio" name="action_type" value="cpt" onChange={per_budget_type.onChange} checked={per_budget_type.value === "cpt"} />
                            按照完成任务奖励KOL
                          </div> */}

                        </div>
                      } else if(sub_type.value === "weibo") {
                        <div className="row">

                          {/* <div className="col-md-4">
                            <input {...per_budget_type} type="radio" name="action_type" id="cpt" value="cpt" onChange={per_budget_type.onChange} checked={per_budget_type.value === "cpt"} />
                            按照完成任务奖励KOL
                          </div> */}

                          <div className="col-md-4">
                            <input {...per_budget_type} type="radio" name="action_type" className="commonPerBudgetType" id="forwarding" value="post" onChange={per_budget_type.onChange} checked={per_budget_type.value === "post"} />
                            按照转发奖励KOL
                          </div>
                        </div>
                      } else {
                        <div></div>
                      }
                  }
                }
            </div>
          </div>

            <div className="action-url-group" style={(per_budget_type && (per_budget_type.value == 'simple_cpi' || per_budget_type.value == 'cpt' || per_budget_type.value == 'cpa')) ? {display: 'block'} : {display: 'none'} }>
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
                          <input {...short_url} type="text" className="action-short-url" readOnly></input>
                          <ShowError field={short_url} />
                          <p className="action-url-notice">请将下载按钮的href或下载完成页的href替换成生成的链接以方便追踪</p>
                        </div>
                        <input {...action_url_identifier} type="hidden" disabled="disabled" className="action_url_identifier" readOnly></input>
                      </div>
                    </div>
                  }else if(per_budget_type.value == 'cpt'){
                    <div className="cpi-tip-label">
                      <label>请把参加的任务链接填入上方<a href="#campaign-link">活动链接</a>处</label>
                    </div>
                  }else{
                    <div className="cpi-tip-label">
                    <label>请把下载链接填入上方<a href="#campaign-link">活动链接</a>处</label>
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

                  <input {...per_action_budget} type="text"
                    className="clearfix spinner-input per-budget-input"
                    style={{display: 'block'}} />
                  <div className="per-budget-input-error">
                    <ShowError field={per_action_budget} optionStyle={"padding-left: 45px"}/>
                  </div>
                  <div className="price-tip">
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'post') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次转发的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'click') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次点击的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'cpa') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次点击的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
                    <p className="stat" style={ (per_budget_type && per_budget_type.value == 'simple_cpi') ? {display: 'block'} : {display: 'none'} }>请设置您想要获得单次下载的成本预算，Robin8将根据大数据分析结果为不同的KOL呈现不同的价格</p>
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
