import React, { PropTypes } from 'react';
import _ from 'lodash';
import { Input } from 'react-bootstrap';

export default class UpdatePostPartial extends React.Component {

  static propTypes = {
    updateName: PropTypes.func.isRequired,
    name: PropTypes.string.isRequired,
  };

  constructor(props, context) {
    super(props, context);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    const name = e.target.value;
    this.props.updateName(name);
  }

  render() {
    const { name } = this.props;

    return (
      <div className="container">
        <h3>
          Hello, {name}!
        </h3>
        <hr/>
        <form className="form-horizontal">
            <Input
              type="text"
              labelClassName="col-sm-2"
              wrapperClassName="col-sm-10"
              label="Say hello to:"
              value={name}
              onChange={this.handleChange}
            />
        </form>
      </div>
    );
  }
}
