import React, { PropTypes } from 'react';
import { Link } from 'react-router';

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
          <div className="brand-logo">
            <Link to={`/brand/${brand.get('id')}/edit`}>
              <img src={ brand.get('avatar_url') } />
            </Link>
          </div>
          <div className="brand-menu">
            <Link to={`/brand/${brand.get('id')}/edit`} className="brand-name">{ brand.get('name') }</Link>
          </div>
        </div>
      </header>
    );
  }
}
