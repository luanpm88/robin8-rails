// See https://www.npmjs.com/package/mirror-creator
// Allows us to set up constants in a slightly more concise syntax. See:
// client/app/bundles/HelloWorld/actions/helloWorldActionCreators.jsx

import mirrorCreator from 'mirror-creator';

const actionTypes = mirrorCreator([
  'HELLO_WORLD_NAME_UPDATE',
]);

// 使用 mirror-creator 的目的:
// actionTypes = {HELLO_WORLD_NAME_UPDATE: "HELLO_WORLD_NAME_UPDATE"}
// Notice how we don't have to duplicate HELLO_WORLD_NAME_UPDATE twice
// thanks to mirror-creator.
export default actionTypes;
