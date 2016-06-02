// 此文件暂未用到
// 把所有子reducer引入到这个文件并combineReducers最好，但暂未尝试成功。


import { combineReducers } from 'redux'
import Immutable from 'immutable';

// import campaignReducer from './campaignReducer';
// import financialReducer from './financialReducer';
// import profileReducer from './profileReducer';
import { initialState as campaignInitialState } from './campaignReducer'
import { initialState as financialInitialState } from './financialReducer'
import { initialState as profileInitialState } from './profileReducer'
