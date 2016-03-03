import React from 'react';

export default class NavPartial extends React.Component {
  render() {
    return (
      <div>
        <header className="navbar r-global-header">
          <div className="container-fluid">
            <a href="landingpage.html" className="logo">Robin8</a>
            <div className="navbar-user pull-right">
              <div className="dropdown ">
                <a href="#" data-toggle="dropdown" className="username">可口可乐COCACOLA<i className="caret-arrow" /></a>
                <ul className="dropdown-menu">
                  <li><a href="#">Action</a></li>
                </ul>
              </div>
            </div>
          </div>
        </header>
        <header className="brand-header">
          <div className="container-fluid">
            <div className="brand-logo"><img src={ require("temp/brand_logo.png") } /></div>
            <div className="brand-menu">
              <div className="dropdown">
                <a href="#" className="brand-name" data-toggle="dropdown">可口可乐COCACOLA<i className="caret-arrow" /></a>
                <ul className="dropdown-menu">
                  <li><a href="#">Action</a></li>
                </ul>
              </div>
            </div>
          </div>
        </header>
      </div>
    );
  }
}
