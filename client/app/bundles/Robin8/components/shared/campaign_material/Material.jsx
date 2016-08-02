import React, { Component } from 'react';

export default class MaterialType extends Component {
  render() {
    const type = this.props.type;
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
}

export class MaterialUrl extends Component {
  render() {
    const { url, type, id, isShow } = this.props;
    return (
      <div>
        <span className="material-url">{url}</span>
        <span className="material-type">{type}</span> {/* 隐藏 */}
        <span className="material-id">{id}</span> {/* 隐藏 */}
        {
          do {
            if (!isShow) {
              <span className="del" onClick={this.props.handleRemove}>x</span>
            }
          }
        }
      </div>
    )
  }
}
