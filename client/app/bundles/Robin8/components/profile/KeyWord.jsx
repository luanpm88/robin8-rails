import React, { Component } from 'react';
import { Button, Input } from 'react-bootstrap';

export default class Keyword extends Component {
  constructor(props) {
    super(props);
    this.add = this.add.bind(this);

    this.keywords = this.props.field.value || this.props.field.initialValue;
    this.keywordList = this.keywords.split(",");
  }

  add() {
    const value = this.refs.input.refs.input.value;

    if(!value) {
      return
    }

    if(!this.keywordList.includes(value)) {
      this.keywordList.push(value);
      this.update();
      this.refs.input.refs.input.value = "";
    }
  }

  update() {
    const { onChange } = this.props.field;
    this.keywords = this.keywordList.join(",");
    onChange(this.keywords);
    // const that = this;
    // setTimeout(function(){
    //   console.log(that.props.field.value);
    // }, 0)
  }

  remove(word) {
    const i = this.keywordList.indexOf(word);
    if(i != -1) {
      this.keywordList.splice(i, 1);
      this.update();
    }
  }

  render() {
    const renderKeywordList = [];
    for(let index in this.keywordList) {
      const word = this.keywordList[index]
      renderKeywordList.push(
        <Button bsSize="xsmall" className="keyword-button" key={index} onClick={this.remove.bind(this, word)}>
          {word}
          <span className="del">x</span>
        </Button>
      );
    }
    return (
      <div>
        {renderKeywordList}

        <div className="add-keyword">
          <img className="search" src={require("search_icon.png")} />
          <Input type="text" ref="input" placeholder="品牌关键词" ref="input" />
          <img className="add" src={require("keyword_add_btn_al.png")} onClick={this.add.bind(event)} />
        </div>
      </div>
    );
  }
}