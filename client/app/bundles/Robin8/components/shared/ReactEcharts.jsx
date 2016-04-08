import React, { PropTypes } from 'react'
// import echarts from 'echarts'
import elementResizeEvent from 'element-resize-event'

class ReactEcharts extends React.Component {
  componentDidMount() {
    const _this = this;

    require.ensure(['echarts'], function(require) {
      const echarts = require("echarts");
      const chart = _this._renderChart(echarts)
      // need to manually resize the chart when the container changes size
      elementResizeEvent.bind(window)(_this.refs.chart, () => {
        chart.resize()
      })
      const { onReady } = _this.props
      if (typeof onReady === 'function') onReady(chart)
    }, 'echarts')
  }

  componentDidUpdate() {
    const _this = this;
    require.ensure(['echarts'], function(require) {
      const echarts = require("echarts");
      _this._renderChart(echarts);
    }, 'echarts')
  }

  componentWillUnmount() {
    echarts.dispose(this.refs.chart)
  }

  _renderChart(echarts) {

    const chartDom = this.refs.chart
    const chart = echarts.getInstanceByDom(chartDom) || echarts.init(chartDom)
    const { option, showLoading } = this.props
    chart.setOption(option)
    if (showLoading) {
      chart.showLoading()
    } else {
      chart.hideLoading()
    }
    return chart
  }

  render() {
    const { height } = this.props

    return (
      <div
        ref="chart"
        style={{height}} />
    )
  }
}

ReactEcharts.propTypes = {
  height: PropTypes.number.isRequired,
  option: PropTypes.object.isRequired,
  showLoading: PropTypes.bool,
  onReady: PropTypes.func
}

export default ReactEcharts
