import React, { PropTypes } from 'react'
// import echarts from 'echarts'
import elementResizeEvent from 'element-resize-event'

class ReactEcharts extends React.Component {
  componentDidMount() {
    const _this = this;

    /*
      这里用的require(AMD)
      也可以用require.ensure(Commonjs)
      根据喜好选择吧，注意区别, require.ensure只获取文件，并不执行，需要自己require
      https://webpack.github.io/docs/code-splitting.html
    */

    require(['echarts'], function(echarts) {
      const chart = _this._renderChart(echarts)
      // need to manually resize the chart when the container changes size
      elementResizeEvent(_this.refs.chart, () => {
        chart.resize()
      })
      const { onReady } = _this.props
      if (typeof onReady === 'function') onReady(chart)
    })
  }

  componentDidUpdate() {
    const _this = this;
    require(['echarts'], function(echarts) {
      _this._renderChart(echarts);
    })
  }

  componentWillUnmount() {
    //echarts.dispose(this.refs.chart)
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
