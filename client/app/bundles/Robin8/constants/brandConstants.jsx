import mirrorCreator from 'mirror-creator';

const actionTypes = mirrorCreator([
  'FETCH_CAMPAIGNS', 'SAVE_CAMPAIGN', 
  'FETCH_CAMPAIGN', 'UPDATE_CAMPAIGN', 'FETCH_INVITES_OF_CAMPAIGN',
  'FETCH_STATISTICS_CLICKS_OF_CAMPAIGN',
  'FETCH_BRAND_PROFILE', 'UPDATE_BRAND_PROFILE'
]);

export default actionTypes;
