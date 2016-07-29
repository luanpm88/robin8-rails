import React from 'react';
import _ from 'lodash';
import {} from '../plupload.full.min'
import 'qiniu-js/dist/qiniu.min.js';

import CampaignMaterialModal from './modals/CampaignMaterialModal';

export default class CampaignMaterialPartial extends React.Component {

  constructor(props, context) {
    super(props, context);

    this.state = {
      showMaterialModal: false,
      materialType: ""
    };
  }

  closeMaterialModal() {
    this.setState({showMaterialModal: false});
  }

  componentDidMount() {
    this.uploadImg();
    this.uploadFile();
  }

  add(material) {
    this.material_array.push(material)
    this.update()
  }

  update() {
    const { onChange } = this.props.materials;
    this.materials = this.material_array
    onChange(JSON.stringify(this.material_array))
  }

  remove(e) {
    const type = $(e.target).parent().find(".material-type").text().trim()
    const url = $(e.target).parent().find(".material-url").text().trim()
    const material = [type, url]
    const index = _.findIndex(this.material_array, function(m) { return m.toString() == material.toString() })
    if(index != -1) {
      this.material_array.splice(index, 1);
      this.update();
    }
  }

  uploadImg() {
    Qiniu.uploader({
        runtimes: 'html5,flash,html4',      // 上传模式,依次退化
        browse_button: 'upload-img',      // 上传选择的点选按钮，**必需**
        uptoken_url: '/brand_api/v1/util/qiniu_token', // Ajax 请求 uptoken 的 Url，**强烈建议设置**（服务端提供）
        get_new_uptoken: false,             // 设置上传文件的时候是否每次都重新获取新的 uptoken
        unique_names: true,                 // 默认 false，key 为文件名。若开启该选项，JS-SDK 会为每个文件自动生成key（文件名）
        domain: '7xozqe.com1.z0.glb.clouddn.com',                   // bucket 域名，下载资源时用到，**必需**
        container: 'material-option',             // 上传区域DOM ID，默认是browser_button的父元素
        max_file_size: '20mb',             // 最大文件体积限制
        flash_swf_url: 'path/of/plupload/Moxie.swf',  //引入 flash,相对路径
        max_retries: 3,                     // 上传失败最大重试次数
        chunk_size: '4mb',                  // 分块上传时，每块的体积
        multi_selection: false,
        auto_start: true,                   // 选择文件后自动上传，若关闭需要自己绑定事件触发上传
        filters : {
          prevent_duplicates: true,
          //Specify what files to browse for
          mime_types: [
            {title : "Image files", extensions : "jpg,gif,png,jpeg"}, //限定jpg,gif,png,jpeg后缀上传
          ]
        },
        init: {
          'FileUploaded': function(up, file, info) {
            const url = up.getOption('domain') + '/' + file.target_name
            var material = []
            material.push('image')
            material.push(url)
            this.add(material)
          }.bind(this)
        }
    });
  }

  uploadFile() {
    Qiniu.uploader({
        runtimes: 'html5,flash,html4',      // 上传模式,依次退化
        browse_button: 'upload-custom',      // 上传选择的点选按钮，**必需**
        uptoken_url: '/brand_api/v1/util/qiniu_token', // Ajax 请求 uptoken 的 Url，**强烈建议设置**（服务端提供）
        get_new_uptoken: false,             // 设置上传文件的时候是否每次都重新获取新的 uptoken
        unique_names: true,                 // 默认 false，key 为文件名。若开启该选项，JS-SDK 会为每个文件自动生成key（文件名）
        domain: '7xozqe.com1.z0.glb.clouddn.com',                   // bucket 域名，下载资源时用到，**必需**
        container: 'material-option',             // 上传区域DOM ID，默认是browser_button的父元素
        max_file_size: '20mb',             // 最大文件体积限制
        flash_swf_url: 'path/of/plupload/Moxie.swf',  //引入 flash,相对路径
        max_retries: 3,                     // 上传失败最大重试次数
        chunk_size: '4mb',                  // 分块上传时，每块的体积
        multi_selection: false,
        auto_start: true,                   // 选择文件后自动上传，若关闭需要自己绑定事件触发上传
        init: {
          'FileUploaded': function(up, file, info) {
            const url = up.getOption('domain') + '/' + file.target_name
            var material = []
            material.push('file')
            material.push(url)
            this.add(material)
          }.bind(this)
        }
    });
  }

  handleUrlClick(type, url) {
    var material = []
    material.push(type)
    material.push(url)
    this.add(material)
  }

  renderMaterailTypeImg(type) {
    switch (type) {
      case 'article':
        return <img src={require("article_material.png")} />
      case 'image':
        return <img src={require("image_material.png")} />
      case 'video':
        return <img src={require("video_material.png")} />
      case 'file':
        return <img src={require("file_material.png")} />
    }
  }

  renderMaterailList() {
    this.materials = this.materials || eval(this.props.materials.value);
    this.material_array = []
    if(this.materials) {
      for(let index in this.materials) {
        this.material_array.push(this.materials[index]);
      }
    }
    const materailList = [];
    for(let index in this.material_array) {
      const material = this.material_array[index]
      const type = material[0]
      const url = material[1]
      materailList.push(
        <li className="" key={index}>
          { this.renderMaterailTypeImg(type) }
          <span className="material-url">{url}</span>
          <span className="material-type">{type}</span> {/* 隐藏掉 */}
          <span className="del" onClick={this.remove.bind(this)}>x</span>
        </li>
      );
    }
    return materailList;
  }

  render() {
    return (
      <div>
        <div className="creat-activity-form creat-material">
          <div className="header">
            <h3 className="tit">活动素材&nbsp;<span className="what" data-toggle="tooltip"><span className="question-sign">?</span></span></h3>
          </div>
          <div className="content">
            <ul className="materials">
              {this.renderMaterailList()}
            </ul>
            <ul className="material-option clearfix" id="material-option">
              <li className="upload-url"><button className="btn btn-blue btn-default" onClick={(e)=>{ e.preventDefault(); this.setState({showMaterialModal: true, materialType: 'article'})}}>填写文章地址</button></li>
              <li><button className="btn btn-blue btn-default" id="upload-img">上传图片</button></li>
              <li className="upload-video"><button className="btn btn-blue btn-default" onClick={(e)=>{ e.preventDefault(); this.setState({showMaterialModal: true, materialType: 'video'})}}>填写视频地址</button></li>
              <li><button className="btn btn-blue btn-default" id="upload-custom">上传自定义文件</button></li>
            </ul>
          </div>
        </div>

        <CampaignMaterialModal className="material-modal" show={this.state.showMaterialModal} onHide={this.closeMaterialModal.bind(this)} type={this.state.materialType} handleUrlClick={this.handleUrlClick.bind(this)} />
      </div>
    )
  }
}
