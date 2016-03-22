import mirrorCreator from 'mirror-creator';

const actionTypes = mirrorCreator([
  'FETCH_CAMPAIGNS', 'SAVE_CAMPAIGN', 'FETCH_CAMPAIGN', 'UPDATE_CAMPAIGN'
]);

export default actionTypes;
