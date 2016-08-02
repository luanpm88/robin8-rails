import React from 'react';
import _ from 'lodash';
import {} from '../plupload.full.min'
import 'qiniu-js/dist/qiniu.min.js';

import MaterialType, { MaterialUrl }    from './Material';
import CampaignMaterialModal        from './modals/CampaignMaterialModal';

export default class CampaignMaterialsPartial extends React.Component {

  constructor(props, context) {
    super(props, context);

    this.material_array = []

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

  saveRecruitCampaignMaterial(material) {
    const url_type = material.type;
    const url = material.url;
    const data = {url_type, url}

    fetch(`/brand_api/v1/campaign_materials`, {
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content'),
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin',
      method: 'POST',
      body: JSON.stringify(data)
    }).then(function(response) {
      response.json().then(function(data){
        this.add(data)
      }.bind(this))
    }.bind(this),
    function(error) {
      console.error("----------创建素材失败---------------")
    })
  }

  add(material) {
    this.material_array.push(material)
    this.update()
  }

  update() {
    const { onChange } = this.props.materials;
    onChange(JSON.stringify(this.material_array))
    const material_ids = _.map(this.material_array, 'id')
    this.props.material_ids.onChange(material_ids);
  }

  remove(e) {
    const id = $(e.target).parent().find(".material-id").text().trim()
    const index = _.findIndex(this.material_array, function(m) { return m.id == id })
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
            var material = {}
            material['type'] = 'image'
            material['url'] = url
            this.saveRecruitCampaignMaterial(material)
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
            var material = {}
            material['type'] = 'file'
            material['url'] = url
            this.saveRecruitCampaignMaterial(material)
          }.bind(this)
        }
    });
  }

  handleUrlClick(type, url) {
    var material = {}
    material['type'] = type
    material['url'] = url
    this.saveRecruitCampaignMaterial(material);
  }

  renderMaterailList() {
    if (this.material_array.length === 0) {
      if (this.materials = eval(this.props.materials.value)) {
        if(this.materials) {
          for(let index in this.materials) {
            this.material_array.push(this.materials[index]);
          }
        }
      }
    }
    const materailList = [];
    for(let index in this.material_array) {
      const material = this.material_array[index]
      const id = material.id
      const type = material.url_type
      const url = material.url
      materailList.push(
        <li className="material" key={index}>
          <MaterialType type={type} />
          <MaterialUrl {...{id, type, url}} isShow={false} handleRemove={this.remove.bind(this)} />
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
