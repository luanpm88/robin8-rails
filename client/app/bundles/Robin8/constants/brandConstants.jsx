import mirrorCreator from 'mirror-creator';

const actionTypes = mirrorCreator([
  'FETCH_CAMPAIGNS', 'SAVE_CAMPAIGN', 'FETCH_CAMPAIGN', 'UPDATE_CAMPAIGN', 'FETCH_BRAND_PROFILE'
]);

export default actionTypes;
