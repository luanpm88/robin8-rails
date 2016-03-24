import React, { Component, PropTypes } from 'react';

export default class showError extends Component {

  static propTypes = {
    field: PropTypes.object.isRequired
  };

  render() {
    const { field } = this.props;

    let style = { color: 'red', marginTop: 8 }

    return (
      <div style={style}>{ (field.touched || field.dirty) && field.error }</div>
    );
  }
}
