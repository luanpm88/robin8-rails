import React from 'react';
import {ShowError} from '../../shared/ShowError';

export default class SubTypePartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, []);
  }

  renderDetailTips() {
    return "";
  }

  componentDidMount() {
  }

  componentWillUnmount() {
  }

  render() {
    const { url, sub_type } = this.props;
    const urlGroupVisible = (sub_type && !!sub_type.value) ? 'block' : 'none';

    return (
      <div className="creat-activity-form creat-content-sources">
        <div className="header">
          <h3 className="tit">活动方式&nbsp;<span className="what" data-toggle="tooltip" title={this.renderDetailTips()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="form-item form-horizontal">
            <p className="action-mode">
              选择活动方式
            </p>
            <div className="container">
              <div className="row">
                <div className="col-md-4">
                  <input {...sub_type} type="radio" name="sub_type" value="wechat" className="commonPerBudgetType"  onChange={sub_type.onChange} checked={sub_type.value === "wechat"} />
                  &nbsp;转发到微信朋友圈
                </div>
                <div className="col-md-4">
                  <input {...sub_type} type="radio" name="sub_type" className="commonPerBudgetType" value="weibo" onChange={sub_type.onChange} checked={sub_type.value === "weibo"} />
                  &nbsp;转发到微博
                </div>
                <div className="col-md-4">
                  <input {...sub_type} type="radio" name="sub_type" value="qq" onChange={sub_type.onChange} checked={sub_type.value === "qq"} />
                  &nbsp;转发到QQ空间
                </div>
                <div className="col-md-4">
                  <input {...sub_type} type="radio" name="sub_type" value="custom" onChange={sub_type.onChange} checked={!sub_type.value} />
                  &nbsp;品牌主自定义
                </div>
              </div>
            </div>
            <div className="url-group" style={{display: urlGroupVisible}}>
              {
                do {
                  if(!!sub_type.value){
                    <div>
                      <div className="url-area clearfix">
                        <p className="url-text">活动链接</p>
                        <div className="url-section">
                          <input {...url} type="text" data-origin-url={url.defaultValue} className="form-control url" placeholder="请填写确认的URL，方便KOL转发和平台活动追踪"></input>
                          <ShowError field={url} />
                        </div>
                      </div>
                    </div>
                  }
                }
              }
            </div>
          </div>
        </div>
      </div>
    )
  }
}
