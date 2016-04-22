import React, { Component } from 'react';
import { findDOMNode } from 'react-dom';

export default class SwitchBox extends Component {
  constructor(props) {
    super(props);

    this.state = { active: false };
  }

  handleClick(e) {
    const element = findDOMNode(this);
    const activeValue = !this.state.active;
    const userData = this.props.userData;

    this.setState({ active: activeValue });
    $(element).toggleClass('active', activeValue);

    if (this.props.onUserClick) {
      this.props.onUserClick(userData, activeValue);
    }
  }

  componentDidMount() {
  }

  render() {
    const text = this.state.active ? '选中' : '未选中';

    return (
      <span className="switchery" onClick={this.handleClick.bind(this)}>
        <small><i></i><i></i><i></i></small>
        <span className="text">{text}</span>
        <input />
      </span>
    );
  }
}