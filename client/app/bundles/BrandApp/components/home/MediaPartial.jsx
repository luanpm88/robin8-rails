import React from 'react';

export default class MediaPartial extends React.Component {
  render() {
    return (
      <div className="panel my-medias-panel">
        <div className="panel-heading">
          <a href="#panelMedias" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <a href="/react/create_activity" target="_blank" className="btn btn-blue btn-big quick-btn">认识新的自媒体</a>
          <h4 className="panel-title">我的御用媒体<i className="carte">/</i><strong className="stat-num">5698</strong></h4>
        </div>
        <div id="panelMedias" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="medias-area">
              {/* 媒体人列表 S */}
              <ul className="medias-list">
                <li className="media-item">
                  <a href="#">
                    <img src={ require("temp/avater1.jpg") } className="avater-small" alt="艾米莉 布朗特" />
                    <span className="txt">艾米莉 布朗特</span>
                  </a>
                </li>
                <li className="media-item">
                  <a href="#">
                    <img src={ require("temp/avater2.jpg") } className="avater-small" alt="Michael Caine" />
                    <span className="txt">Michael Caine</span>
                  </a>
                </li>
                <li className="media-item">
                  <a href="#">
                    <img src={ require("temp/avater3.jpg") } className="avater-small" alt="Natalie Portman" />
                    <span className="txt">Natalie Portman</span>
                  </a>
                </li>
                <li className="media-item">
                  <a href="#">
                    <img src={ require("temp/avater4.jpg") } className="avater-small" alt="凯文·史派西" />
                    <span className="txt">凯文·史派西</span>
                  </a>
                </li>
                <li className="media-item">
                  <a href="#">
                    <img src={ require("temp/avater5.jpg") } className="avater-small" alt="斯嘉丽·约翰逊" />
                    <span className="txt">斯嘉丽·约翰逊</span>
                  </a>
                </li>
                <li className="media-item">
                  <a href="#">
                    <img src={ require("temp/avater6.jpg") } className="avater-small" alt="周星驰" />
                    <span className="txt">周星驰</span>
                  </a>
                </li>
              </ul>
              {/* 媒体人列表 E */}
            </div>
            <a href="#" className="btn btn-grey btn-big btn-line center-block">查看所有候选</a>
          </div>
        </div>
      </div>
    );
  }
}
