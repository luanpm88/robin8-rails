import React, { PropTypes } from 'react';
import { Link } from 'react-router';

export default class BrandNav extends React.Component {
  static propTypes = {
    data: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  componentDidMount() {
    const { fetchBrandProfile } = this.props.actions;
    fetchBrandProfile();
  }


  render() {

    const { actions, data } = this.props;
    const brand = data.get('brand');

    return (
      <header className="navbar r-global-header">
        <div className="container-fluid">
          <Link to="/brand/" className="logo">Robin8</Link>
          <div className="navbar-user pull-right">
            <div className="dropdown ">
              <a href="#" data-toggle="dropdown" className="username">{ brand.get('email') }<i className="caret-arrow"></i></a>
              <ul className="dropdown-menu">
                <li><Link to={`/brand/${brand.get('id')}/edit`}>个人资料</Link></li>
              </ul>
            </div>
          </div>
        </div>
      </header>
    );
  }
}
