import React from 'react';
import { Link } from 'react-router';

export default class BreadCrumb extends React.Component {
  render() {
    return (
      <ol className="breadcrumb">
        <li>
          <i className="caret-arrow left" />
          <Link to="/brand/">我的主页</Link>
        </li>
      </ol>
    );
  }
}
