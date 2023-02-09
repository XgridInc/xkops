import React, { Component } from "react";
import VolumeTable from "./VolumeTable";
import "./VolumeTable.css"
import "./unclaimedVolume.css"

class Unclaimed_Volumes extends Component {

  constructor(props) {
    super(props)
    this.state = {
      records: []
    }
  }

  componentDidMount() {
    fetch("http://a06fc35aeb33f46e3bf19742538467b1-1092220675.ap-southeast-1.elb.amazonaws.com/model/allPersistentVolumes")
      .then(response => response.json())
      .then(records => {
        this.setState({
          records: records.items.filter(record => record.status.phase === "Available")
        })
      })
      .catch(error => console.log(error))
  }

  renderListing() {
    let recordList = []
    this.state.records.map(record => {
      return recordList.push(<li key={record.metadata.name}>{record.metadata.name}</li>)
    })

    return recordList;
  }

  render() {
    return (
      <div>
        <h1 className="header">XkOps - Unclaimed Volumes</h1>
        <div className="table-container">
        <VolumeTable records={this.state.records} />
        </div>
      </div>
    );
  }
}

export default Unclaimed_Volumes;
