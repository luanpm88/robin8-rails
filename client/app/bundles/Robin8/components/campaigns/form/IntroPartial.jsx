import React from 'react';
import Crop from '../../shared/Crop';
import '../../shared/plupload.full.min.js'
import 'qiniu-js/dist/qiniu.min.js';
import { ShowError } from '../../shared/ShowError';

const getUploader = function() {
  return Qiniu.uploader({
    runtimes: 'html5,flash,html4',    //上传模式,依次退化
    browse_button: 'foo',       //上传选择的点选按钮，**必需**
    uptoken_url: '/brand_api/v1/util/qiniu_token',            //Ajax请求upToken的Url，**强烈建议设置**（服务端提供）
    unique_names: true,                 // 默认 false，key 为文件名。若开启该选项，JS-SDK 会为每个文件自动生成key（文件名）
    domain: 'img.robin8.net',   //bucket 域名，下载资源时用到，**必需**
    get_new_uptoken: false,  //设置上传文件的时候是否每次都重新获取新的token
    container: 'form_control_file',           //上传区域DOM ID，默认是browser_button的父元素，
    max_file_size: '4mb',           //最大文件体积限制
    flash_swf_url: 'path/of/plupload/Moxie.swf',  //引入flash,相对路径
    max_retries: 3,                   //上传失败最大重试次数
    dragdrop: true,                   //开启可拖曳上传
    drop_element: 'form_control_file',        //拖曳上传区域元素的ID，拖曳文件或文件夹后可触发上传
    chunk_size: '4mb',                //分块上传时，每片的体积
    auto_start: true,                 //选择文件后自动上传，若关闭需要自己绑定事件触发上传
    multi_selection: false,
    init: {
      'Error': function(up, err, errTip) {
        alert(errTip);

        // $(".brand-error-notice-modal .modal-body").html(errTip);
        // $(".brand-error-notice-modal .modal-title").html("上传失败");
        // $(".brand-error-notice-modal").modal("show");

        // const err_message = null
        // if(err["code"] == -601){
        //     $(".brand-error-notice-modal .modal-body p").html("只支持jpg、gif、png、jpeg格式");
        //     $(".brand-error-notice-modal .modal-title").html("上传失败");
        //     $(".brand-error-notice-modal").modal("show");
        // }else if(err["code"] == -200){
        //   $(".brand-error-notice-modal .modal-body p").html("图片最大不能超过2M");
        //   $(".brand-error-notice-modal .modal-title").html("上传失败");
        //   $(".brand-error-notice-modal").modal("show");
        // }else if(err["code"] == -600){
        //   $(".brand-error-notice-modal .modal-body p").html("图片最大不能超过2M");
        //   $(".brand-error-notice-modal .modal-title").html("上传失败");
        //   $(".brand-error-notice-modal").modal("show");
        // }
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
    threshold: 59,
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
    _.bindAll(this, ['_upload', 'openAnalysisUrl'])
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

  openAnalysisUrl() {
    let targetUrl = encodeURIComponent($("#promotionUrl").val());
    let url = `/brand/campaigns/analysis?url=${targetUrl}`;

    if (!!targetUrl) {
      if (this.props.onLinkAnalysis) {
        this.props.onLinkAnalysis($("#promotionUrl").val())
      }

      window.open(url);
    } else {
      alert("请填写想要分析的链接");
    }
  }

  render() {
    const { name, description, img_url, url } = this.props
    return (
      <div className="creat-activity-form creat-intro">
        <div className="header">
          <h3 className="tit">推广简介&nbsp;</h3>
        </div>
        <div className="content">
          <div className="creat-activity-basic-intro">
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
                <div className="form-control-file" id="form_control_file">

                  {/* 这个input为了配合Crop，不要使用这个做上传（不要设置name） */}
                  <input ref="fileInput" id="fileInput" type="file" style={{display: 'none'}}/>

                  {/* 七牛的bug， 没这个元素不行 */}
                  <button type="button" id="foo" className="btn btn-blue" style={{display: 'none'}}>上传品牌LOGO</button>
                  <label htmlFor="fileInput" id="uploadButton" className="btn btn-blue">上传图片</label>
                </div>
              </div>
            </div>
            <div className="basic-intro common-basic-info">
              <div className="form-group">
                <label htmlFor="campaign-url" id='campaign-link'>活动链接</label>
                <input {...url} id="promotionUrl" className="form-control" placeholder="Robin8将根据此链接统计点击次数，请确定链接真实有效"  />
                <a className="analysis-link btn btn-blue" onClick={this.openAnalysisUrl}>使用NLP智能发布</a>
                <ShowError field={url} />
              </div>
              <div className="form-group">
                <label htmlFor="activityTitle">活动标题</label>
                <input {...name} type="text" className="form-control activity-title-input" maxLength={60} placeholder="请概括您的推广，让您的内容一目了然" />
                <ShowError field={name} />
                <span className="word-limit">60</span>
              </div>
              <div className="form-group">
                <label htmlFor="activityIntro">活动简介</label>
                <textarea {...description} className="form-control common-textarea activity-intro-input" maxLength={500} placeholder="生动有趣的活动介绍，能让KOL对你的活动好感倍增"  ></textarea>
                <span className="word-limit">500</span>
                <ShowError field={description} />
              </div>
            </div>
          </div>
        </div>
        <Crop fileInputSelector={"#fileInput"} doCrop={this._upload} aspectRatio={(16/9)} />
      </div>
     )
   }
 }
