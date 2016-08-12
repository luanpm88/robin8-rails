import _ from "lodash";
import React, { Component } from 'react';
import ReactDOM from 'react-dom';

export default class PriceRangeSelector {
  constructor(opts) {
    let config = {
      elementClass: "price-range-selector",
      parentIsBody: true,
      parentElememt: null,
      onSelectionDone: null
    }

    _.assign(config, opts);

    this.element = null;
    this.elementClass = config.elementClass;
    this.parentIsBody = config.parentIsBody;
    this.parentElememt = config.parentElememt;
    this.onSelectionDone = config.onSelectionDone;
    this.maxValue = -1;
    this.minValue = 0;

    if (!!this.parentIsBody) {
      this.parentElememt = document.createElement("div");
      this.parentElememt.className = "price-range-selector-wrapper";
      document.body.appendChild(this.parentElememt);
    }

    if (!this.parentElememt) {
      throw "[ERROR] You must set parent element.";
    }
  }

  set(min=0, max=-1, state = false) {
    if (min >= 0 && min < max ) {
      this.minValue = min;
      this.maxValue = max;
    }

    if (!!this.onSelectionDone) {
      this.onSelectionDone(this.minValue, this.maxValue, state);
    }
  }

  done() {
    const formElement = $(this.parentElememt).find(".price-inline-form");
    const min = Number.parseInt(formElement.find("input[name='min-price']").val()),
          max = Number.parseInt(formElement.find("input[name='max-price']").val());

    if (!(min >= 0 && min < max)) {
      const formAlert = $(this.parentElememt).find(".price-form-alert");
      formAlert.html("填写的数值错误，请更正").fadeIn().delay(3000).fadeOut();
      return;
    }

    this.minValue = min;
    this.maxValue = max;

    if (!!this.onSelectionDone) {
      this.onSelectionDone(this.minValue, this.maxValue);
    }
    this.hide();
  }

  show() {
    $(this.parentElememt).show();
    $("body").addClass('no-scroll');

    const max = this.maxValue > 0 ? this.maxValue : 10000 ;

    ReactDOM.render(
      <PriceRangeSelectorBox
        elementClass={this.elementClass}
        maxValue={max}
        minValue={this.minValue}
        onCancel={() => this.hide()}
        onFinish={() => this.done()}
      />,
      this.parentElememt);
  }

  hide() {
    $(this.parentElememt).hide();
    $("body").removeClass('no-scroll');

    ReactDOM.unmountComponentAtNode(ReactDOM.findDOMNode(this.parentElememt));
  }
}

class PriceRangeSelectorBox extends Component {
  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ["handleCancel", "handleFinish"])
  }

  handleCancel(event) {
    if (this.props.onCancel) {
      this.props.onCancel(event);
    }
  }

  handleFinish(event) {
    if (this.props.onFinish) {
      this.props.onFinish(event);
    }
  }

  componentDidMount() {
    this.refs.minPrice.value = this.props.minValue;
    this.refs.maxPrice.value = this.props.maxValue;
  }

  render() {
    const { elementClass, maxValue, minValue } = this.props;

    return (
      <div className={`${elementClass} selector-wrap`}>
        <div className="header">
          <h3>请选择价格区间</h3>
        </div>
        <div className="content">
          <div className="price-inline-form">
            <input name="min-price"
              type="number"
              min="0"
              max="10000000"
              step="100"
              ref="minPrice"
            />
            <span className="strip">-</span>
            <input name="max-price"
              type="number"
              min="0"
              max="10000000"
              step="100"
              ref="maxPrice"
            />
          </div>
          <div className="price-form-alert"></div>
        </div>
        <div className="footer">
          <div className="btn selector-done" onClick={ (event) => this.handleFinish(event) }>确定</div>
          <div className="btn selector-cancel" onClick={ (event) => this.handleCancel(event) }>取消</div>
        </div>
      </div>
    );
  }
}