import React from 'react';
import Crop from '../../shared/Crop';
import '../../shared/plupload.full.min.js'
import 'qiniu-js/dist/qiniu.min.js';
import { ShowError } from '../../shared/ShowError';

const getUploader = function() {
  return Qiniu.uploader({
      runtimes: 'html5,flash,html4',      // 上传模式,依次退化
      browse_button: 'foo',      // 上传选择的点选按钮，**必需**
      uptoken_url: '/brand_api/v1/util/qiniu_token', // Ajax 请求 uptoken 的 Url，**强烈建议设置**（服务端提供）
      get_new_uptoken: false,             // 设置上传文件的时候是否每次都重新获取新的 uptoken
      unique_names: true,                 // 默认 false，key 为文件名。若开启该选项，JS-SDK 会为每个文件自动生成key（文件名）
      domain: '7xozqe.com1.z0.glb.clouddn.com',                   // bucket 域名，下载资源时用到，**必需**
      max_file_size: '4mb',             // 最大文件体积限制
      flash_swf_url: 'path/of/plupload/Moxie.swf',  //引入 flash,相对路径
      max_retries: 3,                     // 上传失败最大重试次数
      chunk_size: '4mb',                  // 分块上传时，每块的体积
      multi_selection: false,
      init: {
        'Error': function(up, err, errTip) {
            const err_message = null
            if(err["code"] == -601){
                $(".brand-error-notice-modal .modal-body p").html("只支持jpg、gif、png、jpeg格式");
                $(".brand-error-notice-modal .modal-title").html("上传失败");
                $(".brand-error-notice-modal").modal("show");
            }else if(err["code"] == -200){
              $(".brand-error-notice-modal .modal-body p").html("图片最大不能超过4M");
              $(".brand-error-notice-modal .modal-title").html("上传失败");
              $(".brand-error-notice-modal").modal("show");
            }
        }
      },
      filters : {
        max_file_size : '4mb',
        prevent_duplicates: true,
        // Specify what files to browse for
        mime_types: [
            {title : "Image files", extensions : "jpg,gif,png,jpeg"}, // 限定jpg,gif,png后缀上传
        ]
    },
  });
}

const initBootstrapMaxLength = function() {
  $('.activity-title-input').maxlength({
    threshold: 21,
    placement: 'centered-right',
    appendToParent: '.form-group'
  });

  $('.activity-intro-input').maxlength({
    threshold: 499,
    placement: 'centered-right',
    appendToParent: '.form-group'
  });
}

export default class IntroPartial extends React.Component {
  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_upload'])
  }

  _upload(size, scale) {
    const { img_url } = this.props
    this.uploader.files = [];
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

  componentDidMount() {
    this.uploader = getUploader();
    initBootstrapMaxLength();
  }

  renderTips(){
    const tips = "<p>&nbsp;招募活动采用KOL报名的形式，您只需填写您需要KOL完成的任务，当然这可以是一次线上活动也可以试一次线下活动，我们将为您推送最合适的KOL参加</p>"
    return tips;
  }

  render() {
    const { name, description, img_url } = this.props
    return (
      <div className="creat-activity-form creat-intro">
        <div className="header">
          <h3 className="tit">特邀活动&nbsp;<span className="what" data-toggle="tooltip" title={this.renderTips()}><span className="question-sign">?</span></span></h3>
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
                <textarea {...description}
                  className="form-control common-textarea activity-intro-input"
                  maxLength={500}
                  placeholder="请简要介绍您的推广，帮助媒体了解如何能够更好的帮助您传播，请给出适当的例子，如：请先评论棒极了，再给出买家秀">
                </textarea>
                <span className="word-limit">500</span>
                <ShowError field={description} />
              </div>
            </div>
          </div>
        </div>
        <Crop fileInputSelector={"#fileInput"} className="recruit-img" doCrop={this._upload} aspectRatio={(16/9)} />
      </div>
     )
   }
 }
