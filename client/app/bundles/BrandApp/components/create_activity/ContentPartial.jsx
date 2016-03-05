import React from 'react';

class ContentPartial extends React.Component {
  render() {
    const {forward_url, content, share_url, originality} = this.props;

    return (
      <div className="creat-activity-form creat-content-sources">
        <div className="header">
          <h3 className="tit">推广内容&nbsp;<span className="what">?</span></h3>
        </div>
        <div className="content">
          <div className="form-item form-horizontal">
            <div className="sources-check radio">
              <label>
                <input {...forward_url}  type="radio" name id defaultValue="转发链接" defaultChecked />转发链接
              </label>
            </div>
            <div className="form-group">
              <label htmlFor="promotionContent" className="col-sm-2 control-label">评价内容</label>
              <div className="col-sm-10">
                <input {...content} type="text" id="promotionContent" className="form-control" placeholder="请以自媒体的口吻推荐您的链接内容，方便自媒体转发" required />
              </div>
            </div>
            <div className="form-group">
              <label htmlFor="promotionUrl" className="col-sm-2 control-label">推广链接</label>
              <div className="col-sm-10">
                <input {...share_url}  type="url" id="promotionUrl" className="form-control" placeholder="Robin8将根据此链接统计点击次数，请确定链接真实有效" required />
              </div>
            </div>
          </div>
          <div className="form-item">
            <div className="sources-check radio">
              <label>
                <input {...originality}  type="radio" name id defaultValue="自主创作" />自主创作
              </label>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default ContentPartial;
