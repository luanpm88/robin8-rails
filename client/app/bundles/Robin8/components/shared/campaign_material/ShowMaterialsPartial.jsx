import React from 'react';

import MaterialType, { MaterialUrl }    from './Material';

export default class ShowMaterialsPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    this.material_array = []
  }

  renderMaterailList() {
    if ((this.material_array.length === 0)) {
      var materials = this.props.campaign.get("materials");
      if(materials) {
        materials = eval(materials)
        for(let index in materials) {
          this.material_array.push(materials[index]);
        }
      }
    }
    const materailList = [];
    for(let index in this.material_array) {
      const material = this.material_array[index]
      const id = material.id
      const type = material.url_type
      const url = material.url
      materailList.push(
        <li className="material" key={index}>
          <MaterialType type={type} />
          <MaterialUrl {...{id, type, url}} isShow={true} />
        </li>
      );
    }
    return materailList;
  }

  render() {
    return (
      <div>
        <div className="panel show-activity-form show-material">
          <div className="content">
            <ul className="materials">
              {this.renderMaterailList()}
            </ul>
          </div>
        </div>
      </div>
    )
  }
}
