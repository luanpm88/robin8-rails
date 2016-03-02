import { actionTypes } from '../constants';

export function updateName(name) {
  return {
    type: actionTypes.POST_NAME_UPDATE,
    name,
  };
}
