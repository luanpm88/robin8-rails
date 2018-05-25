import Immutable from 'immutable';
import actionTypes from '../constants/brandConstants';
import _ from 'lodash';

export const initialState = Immutable.fromJS({
  readyState: 'init',
  transactions: [],
  credits: [],
  invoice: {},
  specialInvoice: {},
  invoiceReceiver: {},
  appliableCredits: {},
  invoiceHistories: [],
  error: ""
});

export default function financialReducer($$state = initialState, action=nil) {
  const { type } = action;
  const fetchState = action.readyState;
  switch (type) {
    case actionTypes.ALIPAY_RECHARGE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === "success") {
        if(action.result.alipay_recharge_url) {
          window.location = action.result.alipay_recharge_url;
        }
      } else if (fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
    case actionTypes.FETCH_TRANSACTIONS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "transactions": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate)
        });
      }
      return $$state;

    case actionTypes.FETCH_CREDITS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "credits": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate)
        });
      }
      return $$state;

    case actionTypes.FETCH_COMMON_INVOICE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"invoice": Immutable.fromJS(action.result)});
      }
      return $$state;

    case actionTypes.SAVE_COMMON_INVOICE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"invoice": Immutable.fromJS(action.result)});
      } else if (fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      return $$state;

    case actionTypes.UPDATE_COMMON_INVOICE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"invoice": Immutable.fromJS(action.result)});
      }
      return $$state;

    case actionTypes.FETCH_SPECIAL_INVOICE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"specialInvoice": Immutable.fromJS(action.result)});
      }
      return $$state;

    case actionTypes.SAVE_SPECIAL_INVOICE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"specialInvoice": Immutable.fromJS(action.result)});
      } else if (fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      return $$state;

    case actionTypes.UPDATE_SPECIAL_INVOICE:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"specialInvoice": Immutable.fromJS(action.result)});
      }
      return $$state;

    case actionTypes.FETCH_INVOICE_RECEIVER:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"invoiceReceiver": Immutable.fromJS(action.result)});
      }
      return $$state;

    case actionTypes.SAVE_INVOICE_RECEIVER:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"invoiceReceiver": Immutable.fromJS(action.result)});
      } else if (fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      return $$state;

    case actionTypes.UPDATE_INVOICE_RECEIVER:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"invoiceReceiver": Immutable.fromJS(action.result)});
      }
      return $$state;

    case actionTypes.FETCH_APPLIABLE_CREDITS:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({"appliableCredits": Immutable.fromJS(action.result)});
      }
      return $$state;

    case actionTypes.FETCH_INVOICE_HISTORIES:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "invoiceHistories": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate)
        });
      }
      return $$state;

    case actionTypes.SAVE_INVOICE_HISTORY:
      $$state = $$state.set("readyState", fetchState);
      if(fetchState === 'success') {
        $$state = $$state.merge({
          "invoiceHistories": Immutable.fromJS(action.result.items),
          "paginate": Immutable.fromJS(action.result.paginate)
        });
      } else if (fetchState === "failure"){
        $$state = $$state.merge({ "readyState": fetchState, "error": action.error });
      }
      return $$state;
    default:
      return $$state;
  }
}
