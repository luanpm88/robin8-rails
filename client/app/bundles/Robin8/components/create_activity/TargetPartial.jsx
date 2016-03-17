import React from 'react';

export default class TargetPartial extends React.Component {

  render() {

    const { message, age, province, city, sex } = this.props

    return (
      <div className="creat-activity-form creat-target">
        <div className="header">
          <h3 className="tit">推广目标&nbsp;<span className="what">?</span></h3>
        </div>
        <div className="content">
          <div className="creat-activity-target">
            <div className="form-group">
              <div className="target-age-range">
                <label>年龄段</label>
                <div className="target-age-selector">
                  <select {...age} className="age-range">
                    <option value = "all">全部</option>
                    <option value = "baby">0-5岁</option>
                    <option value = "chidren">5-10</option>
                    <option value = "young">10-20</option>
                    <option value = "man">20-40</option>
                    <option value = "middle_age">40-60</option>
                    <option value = "old">60以上</option>
                  </select>
                </div>
              </div>
              <div className="target-location clearfix" >
                <label>投放地区</label>
                <div className="target-city-selector">
                 <select {...province} className="province"></select>
                 <select {...city} className="city"></select>
                </div>
              </div>
              <div className="target-sex clearfix">
                <label>性别</label>
                <div className="target-sex-selector">
                  <select {...sex} className="sex" >
                    <option value ="all">全部</option>
                    <option value ="male">男</option>
                    <option value ="female">女</option>
                  </select>
                </div>
              </div>
            </div>
          </div>

          <div className="kol-message">
            <p>KOL留言</p>
            <div>
              <input {...message} type="text" className="form-control" placeholder="给KOL留言" required />
            </div>
          </div>

        </div>
      </div>
     )
   }
 }
