import React from 'react';
import "create_activity.css";

export default class CreateActivityPartial extends React.Component {
  render() {
    return (
      <div className="wrapper">
        <div className="container">
          <div className="creat-activity-wrap">
            <form action name id>
              {/* 推广简介 S */}
              <div className="creat-activity-form creat-intro">
                <div className="header">
                  <h3 className="tit">推广简介&nbsp;<span className="what">?</span></h3>
                </div>
                <div className="content">
                  {/* 基本内容 S */}
                  <div className="creat-activity-basic-intro">
                    <div className="cover-photo">
                      <div className="inner">
                        <img id="coverPhotoPlaceholder" />
                        <div className="form-control-file">
                          <span className="btn-upload">上传图片</span><input type="file" id="coverUpload" />
                        </div>
                      </div>
                    </div>
                    <div className="basic-intro">
                      <div className="form-group">
                        <label htmlFor="activityTitle">活动标题</label>
                        <input type="text" className="form-control activity-title-input" maxLength={20} placeholder="请概括您的推广，让您的内容一目了然" required />
                        <span className="word-limit">20</span>
                      </div>
                      <div className="form-group">
                        <label htmlFor="activityIntro">活动简介</label>
                        <textarea name className="form-control activity-intro-input" maxLength={140} placeholder="请简要介绍您的推广，帮助媒体了解如何能够更好的帮您传播，请给出适当的列子，如：请 先评论棒极了，再给出买家秀" required defaultValue={""} />
                        <span className="word-limit">140</span>
                      </div>
                    </div>
                  </div>
                  {/* 基本内容 E */}
                  {/* 关键词设置 S */}
                  <div className="creat-activity-keywords">
                    <div className="form-group">
                      <label>媒体关键词</label>
                      <input type="text" className="form-control activity-keywords-input" placeholder="输入媒体关键词" style={{display: 'none'}} /><div className="bootstrap-tagsinput"><input type="text" placeholder="输入媒体关键词" style={{width: '7em !important'}} /></div>
                      <p className="help-block">您需要具有哪些特点的人帮您传播？用空格分隔</p>
                      <span className="word-limit">5</span>
                    </div>
                  </div>
                  {/* 关键词设置 E */}
                </div>
              </div>
              {/* 推广简介 E */}
              {/* 推广内容 S */}
              <div className="creat-activity-form creat-content-sources">
                <div className="header">
                  <h3 className="tit">推广内容&nbsp;<span className="what">?</span></h3>
                </div>
                <div className="content">
                  <div className="form-item form-horizontal">
                    <div className="sources-check radio">
                      <label>
                        <input type="radio" name id defaultValue="转发链接" defaultChecked />转发链接
                      </label>
                    </div>
                    <div className="form-group">
                      <label htmlFor="promotionContent" className="col-sm-2 control-label">评价内容</label>
                      <div className="col-sm-10">
                        <input type="text" id="promotionContent" className="form-control" placeholder="请以自媒体的口吻推荐您的链接内容，方便自媒体转发" required />
                      </div>
                    </div>
                    <div className="form-group">
                      <label htmlFor="promotionUrl" className="col-sm-2 control-label">推广链接</label>
                      <div className="col-sm-10">
                        <input type="url" id="promotionUrl" className="form-control" placeholder="Robin8将根据此链接统计点击次数，请确定链接真实有效" required />
                      </div>
                    </div>
                  </div>
                  <div className="form-item">
                    <div className="sources-check radio">
                      <label>
                        <input type="radio" name id defaultValue="自主创作" />自主创作
                      </label>
                    </div>
                  </div>
                </div>
              </div>
              {/* 推广内容 E */}
              {/* 推广时间 S */}
              <div className="creat-activity-form creat-date">
                <div className="header">
                  <h3 className="tit">推广时间&nbsp;<span className="what">?</span></h3>
                </div>
                <div className="content">
                  <div className="date-range-form-area input-daterange">
                    <div className="date-box satrt-date">
                      <label>开始时间</label>
                      <input type="text" className="form-control datepicker" name="startDate" readOnly required />
                    </div>
                    <div className="date-box end-date">
                      <label>结束时间</label>
                      <input type="text" className="form-control datepicker" name="endDate" readOnly required />
                    </div>
                  </div>
                </div>
              </div>
              {/* 推广时间 E */}
              {/* 推广预算 S */}
              <div className="creat-activity-form creat-budget">
                <div className="header">
                  <h3 className="tit">推广预算&nbsp;<span className="what">?</span></h3>
                </div>
                <div className="content">
                  {/* 预算价格 S */}
                  <div className="spinner-form-area">
                    <label>总预算</label>
                    <div className="spinner-box">
                      <span className="symbol">$</span>
                      <div className="input-group bootstrap-touchspin"><span className="input-group-btn"><button className="btn btn-default bootstrap-touchspin-down" type="button">-</button></span><span className="input-group-addon bootstrap-touchspin-prefix">$</span><input type="text" defaultValue={0} className="spinner-input budget-input form-control" readOnly style={{display: 'block'}} /><span className="input-group-addon bootstrap-touchspin-postfix" style={{display: 'none'}} /><span className="input-group-btn"><button className="btn btn-default bootstrap-touchspin-up" type="button">+</button></span></div>
                    </div>
                    <p className="stat">最低费用<strong className="stat-num">1000</strong>元</p>
                  </div>
                  {/* 预算价格 E */}
                </div>
              </div>
              {/* 推广预算 E */}
              <div className="creat-form-footer">
                <p className="help-block">以上信息将帮助Robin8精确计算合适的推广渠道，请谨慎填写。在此<a href="#">预览</a></p>
                <button type="submit" className="btn btn-blue btn-lg">查看最优推广渠道</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  }
};