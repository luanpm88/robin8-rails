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

export class BudgetShowError extends Component {

  static propTypes = {
    field: PropTypes.object.isRequired
  };

  render() {
    const { field } = this.props;

    let style = { color: '#ce0101', marginTop: 8, 'fontSize': '10px'}

    return (
      <div style={style}><a href="/brand/financial/recharge" className="budget-show-error" target="_blank">{ (field.touched || field.dirty) && field.error }</a></div>
    );
  }
}
