import React, { Component } from 'react';
import { findDOMNode } from 'react-dom';

export default class SwitchBox extends Component {
  constructor(props) {
    super(props);
  }

  handleClick(e) {
    const activeValue = !this.props.activeValue;
    const userData = this.props.userData;

    if (this.props.onUserClick) {
      this.props.onUserClick(activeValue);
    }
  }

  render() {
    const text = this.props.activeValue ? '选中' : '未选中',
      cls = this.props.activeValue ? 'active' : '';

    return (
      <span className={'switchery ' + cls} onClick={this.handleClick.bind(this)}>
        <small><i></i><i></i><i></i></small>
        <span className="text">{text}</span>
        <input />
      </span>
    );
  }
}