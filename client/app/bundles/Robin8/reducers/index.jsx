import brandReducer from './brandReducer';
import { $$initialState as $$brandState } from './brandReducer';

export default {
  $$brandStore: brandReducer
};

export const initialStates = {
  $$brandState
}
