import React from 'react';

export default class IntroPartial extends React.Component {

  render() {
    const { name, description, image } = this.props

    return (
      <div className="creat-activity-form creat-intro">
        <div className="header">
          <h3 className="tit">推广简介&nbsp;<span className="what">?</span></h3>
        </div>
        <div className="content">
          <div className="creat-activity-basic-intro">
            <div className="cover-photo">
              <div className="inner">
                <img id="coverPhotoPlaceholder" />

                <div className="form-control-file">
                  <span className="btn-upload">上传图片</span>
                  <input {...image} value={ null } type="file" id="coverUpload" />
                </div>
              </div>
            </div>
            <div className="basic-intro">
              <div className="form-group">
                <label htmlFor="activityTitle">活动标题</label>
                <input {...name} type="text" className="form-control activity-title-input" maxLength={20} placeholder="请概括您的推广，让您的内容一目了然" required />
                <span className="word-limit">20</span>
              </div>
              <div className="form-group">
                <label htmlFor="activityIntro">活动简介</label>
                <textarea {...description} name="" className="form-control activity-intro-input" maxLength={140} placeholder="请简要介绍您的推广，帮助媒体了解如何能够更好的帮您传播，请给出适当的列子，如：请 先评论棒极了，再给出买家秀" required ></textarea>
                <span className="word-limit">140</span>
              </div>
            </div>
          </div>
          <div className="creat-activity-keywords">
            <div className="form-group">
              <label>媒体关键词</label>
              <input type="text" className="form-control activity-keywords-input" placeholder="输入媒体关键词" />
              <p className="help-block">您需要具有哪些特点的人帮您传播？用空格分隔</p>
              <span className="word-limit">5</span>
            </div>
          </div>
        </div>
      </div>
     )
   }
 }
