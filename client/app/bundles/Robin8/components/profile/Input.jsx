import React, { Component } from 'react';
import ShowError from '../shared/ShowError';

export default class Input extends Component {
  render() {
    return (
      <div className="form-group">
        <label htmlFor={this.props.id} className="control-label">{this.props.label}</label>
        <div className="control-input">
          <input type={this.props.type || "text"} className="form-control" id={this.props.id} placeholder={this.props.placeholder} {...this.props.field} />
          <ShowError field={this.props.field} />
        </div>
      </div>
    );
  }
}

export class Textarea extends Component {
  render() {
    return(
      <div className="form-group">
        <label htmlFor={this.props.id} className="control-label">{this.props.label}</label>
        <div className="control-input">
          <textarea className="form-control" id={this.props.id} placeholder={this.props.placeholder}  {...this.props.field}>
          </textarea>
          <ShowError field={this.props.field} />
        </div>
      </div>
    );
  }
}

export class RadioButtons extends Component {
  renderRaidoButtons() {
    const pairs = [];

    for(let index in this.props.collection) {
      let pair = this.props.collection[index];
      pairs.push(
        <label key={`label=${index}`}>
          <input {...this.props.field} type="radio" value={pair[1]} checked={this.props.field.value === pair[1]} />
          { pair[0] }
        </label>
      );
    }
    return pairs;
  }

  render() {
    return(
      <div className="form-group">
        <label htmlFor={this.props.id} className="control-label">{this.props.label}</label>
        <div className="control-input radio-button-group" style={{textAlign: 'left'}}>
          {this.renderRaidoButtons()}
        </div>
      </div>
    );
  }
}