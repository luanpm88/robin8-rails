import React from 'react';

export default class NavPartial extends React.Component {
  render() {
    console.log(this.props.currentUser)
    window.x = this.props.currentUser;
    return (
      <header className="navbar r-global-header">
        <div className="container-fluid">
          <a href="landingpage.html" className="logo">Robin8</a>
          <div className="navbar-user pull-right">
            <div className="dropdown ">
              <a href="#" data-toggle="dropdown" className="username">
                <span>{this.props.currentUser.get('name')}</span>
                <i className="caret-arrow" />
              </a>
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
