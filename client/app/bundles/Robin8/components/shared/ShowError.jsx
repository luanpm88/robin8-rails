import React, { Component, PropTypes } from 'react';

export default class showError extends Component {

  static propTypes = {
    field: PropTypes.object.isRequired
  };

  render() {
    const { field } = this.props;

    return (
      <div style={{color: 'red'}}>{ field.touched && field.error }</div>
    );
  }
}
