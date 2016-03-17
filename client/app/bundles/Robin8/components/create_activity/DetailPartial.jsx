import React from 'react'
import _ from 'lodash'

export default class DetailPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
  }


  _fetchShortUrl = (e) => {
    e.preventDefault()
    let action_url = $(".action-url").val()
    let brand_id = this.props.brand_id.toString();
    let timestamps = Math.floor(Date.now()).toString();
    let random = Math.floor(Math.random() * 100000).toString();
    let identifier = brand_id + timestamps + random
    $.ajax({
      method: "GET",
      url: '/brand_api/v1/campaigns/short_url',
      data: { url: action_url, identifier: identifier }
    }).done(function(data) {
      $(".action-short-url").val(data);
      $(".action_url_identifier").val(identifier);
    })
  }

  render() {

    const { per_budget_type, action_url, action_url_identifier, short_url, per_action_budget } = this.props

    return (
      <div className="creat-activity-form creat-content-sources">
        <div className="header">
          <h3 className="tit">推广详情&nbsp;<span className="what">?</span></h3>
        </div>
        <div className="content">
          <div className="form-item form-horizontal">
            <p className="action-mode">
              奖励模式选择
            </p>
            <div className="sources-check radio">
              <label>
                <input {...per_budget_type} type="radio" name="action_type" value="click" defalutValue="转发链接" defaultChecked />
                按照发布奖励KOL
              </label>
              <label>
                <input {...per_budget_type} type="radio" name="action_type" value="post" defalutValue="转发链接" />
                按照点击奖励KOL
              </label>
              <label>
                <input {...per_budget_type} type="radio" name="action_type" value="action" defalutValue="转发链接" />
                按照行动奖励KOL
              </label>
            </div>

            <div className="action-url-group" style={{display: 'none'}}>
              <div className="clearfix">
                <p className="action-url-text">确认链接</p>
                <input {...action_url} type="text" className="form-control action-url" placeholder="请填写确认页的URL方便追踪行动是否完成"></input>
              </div>
              <div className="clearfix">
                <button className="btn btn-blue btn-default generate-short-url-btn" onClick={this._fetchShortUrl}>生成链接</button>
              </div>
              <div className="clearfix">
                <p className="generate-short-url-text">生成链接</p>
                <input {...short_url} type="text" className="action-short-url" disabled="disabled" readOnly></input>
                <p className="action-url-notice">请将下载按钮的href或下载完成页的href替换成生成的链接以方便追踪</p>
                <input {...action_url_identifier} type="hidden" disabled="disabled" className="action_url_identifier" readOnly></input>
              </div>
            </div>

            <div className="per-budget-group">
              <p className="per-budget-text">单次预算</p>
              <div className="spinner-form-area">
                <div className="spinner-box">
                  <span className="symbol">$</span>
                  <input {...per_action_budget} type="text" defaultValue={0} className="spinner-input per-budget-input" style={{display: 'block'}} />
                  <p className="average-price">均价xxx</p>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    )

  }
}
