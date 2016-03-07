console.log("in BrandNav");

import React, { PropTypes } from 'react'

export default class BrandNav extends React.Component {
  static propTypes = {
    data: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  render() {

    const { actions, data } = this.props;
    const brand = data.get('brand');

    return (
      <header className="navbar r-global-header">
        <div className="container-fluid">
          <a href="#" className="logo">Robin8</a>
          <div className="navbar-user pull-right">
            <div className="dropdown ">
              <a href="#" data-toggle="dropdown" className="username">{ brand.get('email') }<i className="caret-arrow"></i></a>
              <ul className="dropdown-menu">
                <li><a href="#">Action</a></li>
              </ul>
            </div>
          </div>
        </div>
      </header>
    );
  }
}
