console.log("in BrandHeader");

import React, { PropTypes } from 'react'

export default class BrandHeader extends React.Component {
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
      <header className="brand-header">
        <div className="container-fluid">
          <div className="brand-logo"><img src={ brand.get('avatar_url') } /></div>
          <div className="brand-menu">
            <div className="dropdown">
              <a href="#" className="brand-name" data-toggle="dropdown">{ brand.get('email') }<i className="caret-arrow"></i></a>
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
