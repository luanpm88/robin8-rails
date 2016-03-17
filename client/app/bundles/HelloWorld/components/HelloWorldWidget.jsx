// HelloWorldWidget is an arbitrary name for any "dumb" component. We do not recommend suffixing
// all your dump component names with Widget.

// loadsh 介绍
// https://lodash.com/
// http://www.infoq.com/cn/news/2015/03/lodash-utility-library
// _.assign({ 'a': 1 }, { 'b': 2 }, { 'c': 3 });
// → { 'a': 1, 'b': 2, 'c': 3 }
// _.map([1, 2, 3], function(n) { return n * 3; });
// → [3, 6, 9]

import React, { PropTypes } from 'react';
import _ from 'lodash'; 
import { Input } from 'react-bootstrap';

// Simple example of a React "dumb" component
export default class HelloWorldWidget extends React.Component {
  // 表示 需要传人的参数, 以及 对应的类型。
  static propTypes = {
    // If you have lots of data or action properties, you should consider grouping them by
    // passing two properties: "data" and "actions".

    updateName: PropTypes.func.isRequired,
    name: PropTypes.string.isRequired,
  };

  constructor(props, context) {
    super(props, context);

    // Uses lodash to bind all methods to the context of the object instance, otherwise
    // the methods defined here would not refer to the component's class, not the component
    // instance itself.

    _.bindAll(this, 'handleChange');
  }

  // React will automatically provide us with the event `e`
  handleChange(e) {
    // updateName 是从哪里来的
    const name = e.target.value;
    this.props.updateName(name);
  }

  render() {
    // 这种写法的 好处 是什么?
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
