import React, { Component, PropTypes } from 'react';

export default class showError extends Component {

  static propTypes = {
    field: PropTypes.object.isRequired
  };

  render() {
    const { field } = this.props;

    let style = { color: '#ce0101', marginTop: 8, 'font-size': '10px'}

    return (
      <div style={style}>{ (field.touched || field.dirty) && field.error }</div>
    );
  }
}
