import cookie from 'react-cookie';

export default function isSuperVistor() {
  return reactCookie.load('is_super_vistor') ? true : false;
}
