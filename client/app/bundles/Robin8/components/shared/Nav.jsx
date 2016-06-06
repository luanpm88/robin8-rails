import React, { PropTypes } from 'react';
import { Link } from 'react-router';

export default class BrandNav extends React.Component {
  static propTypes = {
    profileData: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context);
  }

  componentDidMount() {
    const { fetchBrandProfile } = this.props.actions;
    fetchBrandProfile();
  }


  render() {

    const { actions, profileData } = this.props;
    const brand = profileData.get('brand');

    return (
      <header className="navbar r-global-header">
        <div className="container-fluid">
          <Link to="/brand/" className="logo">Robin8</Link>
          <div className="navbar-user pull-right">
            <div className="dropdown ">
              <a href="#" data-toggle="dropdown" className="username">{ brand.get('name') }<i className="caret-arrow"></i></a>
              <ul className="dropdown-menu">
                <li><Link to={`/brand/${brand.get('id')}/edit`}>品牌资料</Link></li>
                <li><Link to={'/brand/password'}>修改密码</Link></li>
                <li><Link to={'/brand/financial/recharge'}>充值</Link></li>
                <li><a href="/users/sign_out">退出</a></li>
              </ul>
            </div>
          </div>
        </div>
      </header>
    );
  }
}
