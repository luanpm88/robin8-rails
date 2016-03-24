import Immutable from 'immutable';

export const $$initialState = Immutable.fromJS({
  name: 'unknow',
  guid: 'unknow'
});

export default function CurrentUserReducer($$state = $$initialState, action) {
  const { type, name } = action;

  switch (type) {
    default:
      return $$state;
  }
}
