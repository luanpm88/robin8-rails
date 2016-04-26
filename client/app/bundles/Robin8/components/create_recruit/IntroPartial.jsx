import React from 'react';
import Crop from '../shared/Crop';
import 'qiniu-js/dist/qiniu.min.js';
import { ShowError } from '../shared/ShowError';

const getUploader = function() {
  return Qiniu.uploader({
      runtimes: 'html5,flash,html4',      // 上传模式,依次退化
      browse_button: 'foo',      // 上传选择的点选按钮，**必需**
      uptoken_url: '/brand_api/v1/util/qiniu_token', // Ajax 请求 uptoken 的 Url，**强烈建议设置**（服务端提供）
      get_new_uptoken: false,             // 设置上传文件的时候是否每次都重新获取新的 uptoken
      unique_names: true,                 // 默认 false，key 为文件名。若开启该选项，JS-SDK 会为每个文件自动生成key（文件名）
      domain: '7xozqe.com1.z0.glb.clouddn.com',                   // bucket 域名，下载资源时用到，**必需**
      max_file_size: '100mb',             // 最大文件体积限制
      flash_swf_url: 'path/of/plupload/Moxie.swf',  //引入 flash,相对路径
      max_retries: 3,                     // 上传失败最大重试次数
      chunk_size: '4mb',                  // 分块上传时，每块的体积
      multi_selection: false,
      init: {}
  });
}

const initBootstrapMaxLength = function() {
  $('.activity-title-input').maxlength({
    threshold: 21,
    placement: 'centered-right',
    appendToParent: '.form-group'
  });

  $('.activity-intro-input').maxlength({
    threshold: 139,
    placement: 'centered-right',
    appendToParent: '.form-group'
  });

  $('.activity-task-input-input').maxlength({
    threshold: 139,
    placement: 'centered-right',
    appendToParent: '.form-group'
  });

  
}

export default class IntroPartial extends React.Component {
  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_upload', 'handleHideBrandNameChange', "handleChangeTaskTemplate"])
    this.currentTaskDescriptioinIndex = -1
    this.taskDescTemplate = [
      "准时参与品牌活动, 完成品牌指定任务, 发送照片及文字至朋友圈并保证发布时间持续30分钟",
      "准备到达指定地点签到并参与活动, 用图片或视频记录参与过程, 发送图片或视频到朋友圈并持续30分钟",
      "按时参加品牌活动, 配合品牌完成相关体验, 记录体验过程,发送图片或小视频至朋友圈"
    ]
  }

  _upload(size, scale) {
    const { img_url } = this.props

    this.uploader.refresh();
    this.uploader.addFile(this.refs.fileInput.files[0]);
    this.uploader.bind("FileUploaded", function(up, file, info) {
      const domain = up.getOption('domain');
      const url = 'http://' + domain + `/${file.target_name}?imageMogr2/crop/!${size.w * scale}x${size.h * scale}a${size.x * scale}a${size.y * scale}`;

      $('#coverPhotoPlaceholder').attr('src', url);
      img_url.onChange(url);
    });

    this.uploader.start();
  }

  handleChangeTaskTemplate(){
    let currentIndex = Number.parseInt($(".changeTaskDescTemplate").attr("data-current-template"))+ 1
    if (currentIndex >= this.taskDescTemplate.length){
      currentIndex = 0
    }

    this.props.task_description.onChange(this.taskDescTemplate[currentIndex]);
    $(".changeTaskDescTemplate").attr("data-current-template", currentIndex + 1)
  }

  componentDidMount() {
    this.uploader = getUploader();
    initBootstrapMaxLength();
  }

  handleHideBrandNameChange(){
    const { onChange } = this.props.hide_brand_name;
    onChange(!this.props.hide_brand_name.value)
  }

  render() {
    const { name, description, img_url, url, task_description, address, hide_brand_name} = this.props
    return (
      <div className="creat-activity-form creat-intro">
        <div className="header">
          <h3 className="tit">推广简介&nbsp;</h3>
        </div>
        <div className="content">
          <div className="creat-activity-basic-intro create-recruit-basic-info">
            <div className="cover-photo">
              <div className="inner">
                { do
                  {
                    if (img_url.initialValue)
                      <img src={img_url.initialValue} id="coverPhotoPlaceholder" />
                    else
                      <img src={require("campaign-pic.jpg")} id="coverPhotoPlaceholder" />
                  }
                }
                <ShowError field={img_url} />
                <div className="form-control-file">

                  {/* 这个input为了配合Crop，不要使用这个做上传（不要设置name） */}
                  <input ref="fileInput" id="fileInput" type="file" style={{display: 'none'}}/>

                  {/* 七牛的bug， 没这个元素不行 */}
                  <button type="button" id="foo" className="btn btn-blue" style={{display: 'none'}}>上传品牌LOGO</button>
                  <label htmlFor="fileInput" id="uploadButton" className="btn btn-blue">上传图片</label>
                </div>
              </div>
            </div>
            <div className="basic-intro recruit-basic-info">
              <div className="form-group">
                <label htmlFor="activityTitle">活动标题</label>
                <input {...name} type="text" className="form-control activity-title-input" maxLength={22} placeholder="请概括您的推广，让您的内容一目了然" />
                <ShowError field={name} />
                <span className="word-limit">22</span>
              </div>
              <div className="form-group">
                <label htmlFor="activityIntro">活动简介</label>
                <textarea {...description} className="form-control common-textarea activity-intro-input" maxLength={140} placeholder="生动有趣的活动介绍，能让KOL对你的活动好感倍增"  ></textarea>
                <span className="word-limit">140</span>
                <ShowError field={description} />
              </div>
              <div className="form-group">
                <label htmlFor="activityIntro">任务描述</label>
                <span className="changeTaskDescTemplate pull-right" data-current-template="1" onClick={this.handleChangeTaskTemplate}>换个模板</span>
                <textarea {...task_description} className="form-control  common-textarea activity-task-input-input" maxLength={140} placeholder="描述KOL需要完成的活动及推广任务。不会填写？点击“换个模板”试试看"  ></textarea>
                <span className="word-limit">140</span>
                <ShowError field={task_description} />
              </div>
              <div className="form-group">
                <label htmlFor="campaign-address">活动地址</label>
                <input {...address} className="form-control recruit-address-input" placeholder="非线下活动可不填写"  />
              </div>
              <div className="form-group">
                <label className="recruit-brand-name-showable">
                  <input type="checkbox" defaultChecked={hide_brand_name.value} onChange={this.handleHideBrandNameChange}></input>
                  <label>活动发布时隐藏品牌名称</label>
                </label>
              </div>
            </div>
          </div>
        </div>
        <Crop fileInputSelector={"#fileInput"} className="recruit-img" doCrop={this._upload} aspectRatio={(16/9)} />
      </div>
     )
   }
 }
