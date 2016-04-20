import Immutable from 'immutable';
import actionTypes from '../constants/brandConstants';

export const $$initialState = Immutable.fromJS({
  readyState: 'init',
  brand: {},
  campaignList: [],
  paginate: {},
  campaign: {},
  campaign_invites: [],
  hasfetchedInvite: false,
  campaign_statistics: [],
  error: ""
});

export default function brandReducer($$state = $$initialState, action = null) {
  const { type, campaignList } = action;
  const fetchState = action.readyState;
  switch (type) {
    case actionTypes.FETCH_CAMPAIGNS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "campaignList": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate)
        });
      }
      return $$state;

    case actionTypes.SAVE_CAMPAIGN:
      if(fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState });
      }

      return $$state;

    case actionTypes.UPDATE_CAMPAIGN:
      if(fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      console.log("fetchState" + fetchState);
      return $$state;

    case actionTypes.FETCH_RECRUIT_CAMPAIGN:
      // action.result = {
      //   name: "可口可乐带你过大年11",
      //   status: "unexecute",
      //   start_time: Date.now(),
      //   end_time: Date.now(),
      //   address: "上海市 静安区 江宁路77号",
      //   task_description: "请大家行动起来，一起转发下面的活动，迎接新的一年!请大家行动起来，一起转发下面的活动，迎接新的一年!请大家行动起来，一起转发下面的活动，迎接新的一年!",
      //   recruit_start_time: new Date("2016/04/18 05:30:01"),
      //   recruit_end_time: new Date("2016/04/24 08:00:05"),
      //   img_url: "http://7xozqe.com1.z0.glb.clouddn.com/o_1agkabe9k146v1es6nrf13q918cuc.gif?imageMogr2/crop/!751.1737089201877x422.53521126760563a35.2112676056338a100",
      //   per_action_budget: 100,
      //   budget: 1000
      // };
      $$state = $$state.set("readyState", 'success');
      $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
      return $$state;
    case actionTypes.FETCH_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "campaign": Immutable.fromJS(action.result) });
      }
      // console.log($$state.toObject().campaign.toObject())
      return $$state;
    case actionTypes.FETCH_BRAND_PROFILE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({ "brand": Immutable.fromJS(action.result) });
      }
      return $$state;
    case actionTypes.UPDATE_BRAND_PROFILE:
      return $$state;

    case actionTypes.UPDATE_BRAND_PASSWORD:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      if(fetchState === 'success') {
        window.location = '/users/sign_out';
        window.location = '/';
      }
      return $$state;

    case actionTypes.FETCH_INVITES_OF_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success"){
        $$state = $$state.merge({
          "campaign_invites": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate),
          "hasfetchedInvite": true
        });
      }
      return $$state;
    case actionTypes.FETCH_STATISTICS_CLICKS_OF_CAMPAIGN:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success"){
        $$state = $$state.merge({
          "campaign_statistics": Immutable.fromJS(action.result.items),
        })
      }
      return $$state;
    default:
      return $$state;
  }
}
