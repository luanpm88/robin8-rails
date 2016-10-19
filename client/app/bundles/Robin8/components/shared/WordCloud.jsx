import React, { PropTypes } from 'react'

import './jqcloud.min.js';

class WordCloud extends React.Component {
  componentDidMount() {
    this.renderCloud();
  }

  componentDidUpdate() {
    this.renderCloud();
  }

  renderCloud() {
    const { words } = this.props;
    const container = $(this.refs.wordCloud);
    container.html("");
    container.jQCloud(words);
  }

  render() {
    const { height, width } = this.props

    return (
      <div ref="wordCloud" style={{height, width}}></div>
    )
  }
}

export default WordCloud
