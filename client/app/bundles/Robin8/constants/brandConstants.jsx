import mirrorCreator from 'mirror-creator';

const actionTypes = mirrorCreator([
  'FETCH_CAMPAIGNS', 'SAVE_CAMPAIGN', 'FETCH_CAMPAIGN', 'UPDATE_CAMPAIGN', 'FETCH_INVITES_OF_CAMPAIGN'
]);

export default actionTypes;
