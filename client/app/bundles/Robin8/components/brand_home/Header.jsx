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
              {
                do {
                  if(brand.get('avatar_url'))
                    <img src={ brand.get('avatar_url') } />
                  else
                    <img ref="logo" src={require('brand-profile-pic.jpg')} />
                }
              }

            </Link>
          </div>
          <div className="brand-content">
            <Link to={`/brand/${brand.get('id')}/edit`} className="brand-name">{ brand.get('name') }</Link>
          </div>
        </div>
      </header>
    );
  }
}
