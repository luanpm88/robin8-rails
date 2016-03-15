import React from 'react';

export default class DetailPartial extends React.Component {

  render() {

    const { forward_url, content, url, originality } = this.props

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
                <input {...forward_url} type="radio" name="action_type" value="click" defalutValue="转发链接" defaultChecked />
                按照发布奖励KOL
              </label>
              <label>
                <input {...forward_url} type="radio" name="action_type" value="post" defalutValue="转发链接" />
                按照点击奖励KOL
              </label>
              <label>
                <input {...forward_url} type="radio" name="action_type" value="action" defalutValue="转发链接" />
                按照行动奖励KOL
              </label>
            </div>

            <div className="action-url-group" style={{display: 'none'}}>
              <div className="clearfix">
                <p className="action-url-text">确认链接</p>
                <input type="text" className="form-control action-url" placeholder="请填写确认页的URL方便追踪行动是否完成"></input>
              </div>
              <div className="clearfix">
                <button className="btn btn-blue btn-default generate-short-url-btn">生成链接</button>
              </div>
              <div className="clearfix">
                <p className="generate-short-url-text">生成链接</p>
                <input type="text" className="action-short-url" readOnly></input>
                <p className="action-url-notice">请将下载按钮的href或下载完成页的href替换成生成的链接以方便追踪</p>
              </div>
            </div>

            <div className="per-budget-group">
              <p className="per-budget-text">单次预算</p>
              <div className="spinner-form-area">
                <div className="spinner-box">
                  <span className="symbol">$</span>
                  <input type="text" defaultValue={0} className="spinner-input budget-input" style={{display: 'block'}} />
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
