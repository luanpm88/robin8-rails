import _ from "lodash";
import React, { Component } from 'react';
import ReactDOM from 'react-dom';

const baseUrl = "/brand_api/v1"

export default class ProfessionSelector {
  constructor(opts) {
    let config = {
      activeItems: [],
      elementClass: "profession-selector",
      parentIsBody: true,
      parentElememt: null,
      onSelectionDone: null,
      dataUrl: `${baseUrl}/util/professions`
    }

    _.assign(config, opts);

    this.elementClass = config.elementClass;
    this.parentIsBody = config.parentIsBody;
    this.parentElememt = config.parentElememt;
    this.onSelectionDone = config.onSelectionDone;
    this.dataUrl = config.dataUrl;
    this.activeItems = config.activeItems;
    this.items = [];

    if (!!this.parentIsBody) {
      this.parentElememt = document.createElement("div");
      this.parentElememt.className = "profession-selector-wrapper";
      document.body.appendChild(this.parentElememt);
    }

    if (!this.parentElememt) {
      throw "[ERROR] You must set parent element.";
    }
  }

  load(callback) {
    if (!!this.items && this.items.length > 0) {
      callback();
    } else {
      fetch(this.dataUrl, { credentials: 'same-origin' })
        .then(response => response.json())
        .then(data => {
          this.items = data.items;
          callback();
        })
        .catch(e => {
          console.log("[ERROR]", e)
        })
    }
  }

  set(values, state = false) {
    let targetItems = [];

    this.load(() => {
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
    });
  }

  done() {
    let activeElements = $(this.parentElememt).find(".pfs-item.active");
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

    this.load(() => ReactDOM.render(
      <ProfessionSelectorBox
        items={this.items}
        activeItems = {this.activeItems}
        elementClass={this.elementClass}
        onCancel={() => this.hide()}
        onFinish={() => this.done()}
      />, this.parentElememt));
  }

  hide() {
    $(this.parentElememt).hide();
    $("body").removeClass('no-scroll');

    ReactDOM.unmountComponentAtNode(ReactDOM.findDOMNode(this.parentElememt));
  }
}

class ProfessionSelectorBox extends Component {
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
    let professionItems = [];

    items.map((item) => {
      let state = "";
      if (_.some(activeItems, ['id', item.id])) {
        state = "active"
      }

      const element =
        <div
          key={`pfs-${item.id}`}
          className={`item pfs-item ${state}`}
          onClick={ this.handleSelect.bind(this) }
          data-id={item.id}
          data-name={item.name}>
          { item.label }
        </div>
      professionItems.push(element);
    });

    return (
      <div className={`${elementClass} selector-wrap`}>
        <div className="header">
          <h3>请选择分类</h3>
        </div>
        <div className="content">
          <div className="item-list">
            {professionItems}
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