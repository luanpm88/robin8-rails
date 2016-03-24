import React, { Component, PropTypes } from 'react';

export default class showError extends Component {

  static propTypes = {
    field: PropTypes.object.isRequired
  };

  render() {
    const { field } = this.props;

    let style = { color: 'red', marginTop: 8 }

    if (field.name === 'per_action_budget') {
      style = {color: 'red', marginTop: 8, paddingLeft: 45}
    } else if (field.name === 'action_url' || field.name === 'short_url') {
      style = {color: 'red', marginTop: 8, paddingLeft: 140}
    }

    return (
      <div style={style}>{ (field.touched || field.dirty) && field.error }</div>
    );
  }
}
