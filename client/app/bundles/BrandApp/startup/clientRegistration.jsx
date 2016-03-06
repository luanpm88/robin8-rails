require('es6-promise').polyfill();
require('isomorphic-fetch');

import ReactOnRails from 'react-on-rails';
import BrandApp from './BrandAppClient';

ReactOnRails.register({ BrandApp });
