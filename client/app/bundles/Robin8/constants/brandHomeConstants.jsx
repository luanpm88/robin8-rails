import mirrorCreator from 'mirror-creator'

const actionTypes = mirrorCreator([
  'SET_IS_FETCHING', 'FETCH_CAMPAIGN_LIST_SUCCESS', 'FETCH_CAMPAIGN_LIST_FAILURE'
]);

export default actionTypes;
