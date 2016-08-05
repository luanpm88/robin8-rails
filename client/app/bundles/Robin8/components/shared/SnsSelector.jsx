import _ from "lodash";
import React, { Component } from 'react';
import ReactDOM from 'react-dom';

export default class SnsSelector {
  constructor(opts) {
    let config = {
      activeItems: [],
      elementClass: "sns-selector",
      parentIsBody: true,
      parentElememt: null,
      onSelectionDone: null
    }

    _.assign(config, opts);

    this.elementClass = config.elementClass;
    this.parentIsBody = config.parentIsBody;
    this.parentElememt = config.parentElememt;
    this.onSelectionDone = config.onSelectionDone;
    this.activeItems = [];
    this.items = [
      {
        id: 1,
        label: "微博",
        name: "weibo"
      },
      {
        id: 2,
        label: "微信",
        name: "public_wechat"
      },
      {
        id: 3,
        label: "QQ",
        name: "qq"
      }
    ];

    if (!!this.parentIsBody) {
      this.parentElememt = document.createElement("div");
      this.parentElememt.className = "sns-selector-wrapper";
      document.body.appendChild(this.parentElememt);
    }

    if (!this.parentElememt) {
      throw "[ERROR] You must set parent element.";
    }
  }

  set(values, state=false) {
    let targetItems = [];

    _.forEach(values, (value) => {
      const item = _.find(this.items, {'name': value});
      if (!!item) {
        targetItems.push(item);
      }
    });

    this.activeItems = targetItems;
    if (!!this.onSelectionDone) {
      this.onSelectionDone(this.activeItems, state);
    }
  }

  done() {
    let activeElements = $(this.parentElememt).find(".sns-item.active");
    const items = this.items;

    this.activeItems = [];
    _.forEach(activeElements, (element) => {
      const itemId = $(element).data("id");
      const activeItem = _.find(items, (item) => { return item.id == itemId });

      this.activeItems.push(activeItem);
    });

    if (!!this.onSelectionDone) {
      this.onSelectionDone(this.activeItems);
    }
    this.hide();
  }

  show() {
    $(this.parentElememt).show();
    $("body").addClass('no-scroll');

    ReactDOM.render(
      <SnsSelectorBox
        items={this.items}
        activeItems = {this.activeItems}
        elementClass={this.elementClass}
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

class SnsSelectorBox extends Component {
  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ["handleCancel", "handleFinish", "handleSelect"])
  }

  handleSelect(event) {
    $(event.target).toggleClass('active');
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

  render() {
    const { items=[], activeItems=[], elementClass } = this.props;
    let snsItems = [];

    items.map((item) => {
      let state = "";
      if (_.some(activeItems, ['id', item.id])) {
        state = "active"
      }

      const element =
        <div
          key={`sns-${item.id}`}
          className={`item sns-item sns-icon ${state} icon-${item.name}`}
          onClick={ this.handleSelect.bind(this) }
          data-id={item.id}>
        </div>
      snsItems.push(element);
    });

    return (
      <div className={`${elementClass} selector-wrap`}>
        <div className="header">
          <h3>请选择社交媒体</h3>
        </div>
        <div className="content">
          <div className="item-list">
            {snsItems}
          </div>
        </div>
        <div className="footer">
          <div className="btn selector-done" onClick={ (event) => this.handleFinish(event) }>确定</div>
          <div className="btn selector-cancel" onClick={ (event) => this.handleCancel(event) }>取消</div>
        </div>
      </div>
    );
  }
}
