import React, { Component, PropTypes } from 'react';

export class ShowError extends Component {

  static propTypes = {
    field: PropTypes.object.isRequired
  };

  render() {
    const { field } = this.props;

    let style = { color: '#ce0101', marginTop: 8, 'fontSize': '10px'}

    return (
      <div style={style}>{ (field.touched || field.dirty) && field.error }</div>
    );
  }
}
