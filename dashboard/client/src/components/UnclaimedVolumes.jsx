import React, { Component } from 'react'
import VolumeTable from './VolumeTable'
import './VolumeTable.css'
import './unclaimedVolume.css'

class UnclaimedVolumes extends Component {
  constructor (props) {
    super(props)
    this.state = {
      records: []
    }
  }

  async componentDidMount () {
    let data = 'None'
    data = await fetch('/allPersistentVolumes')
    console.log(data.json())

    // .then(records => {
    //   this.setState({
    //     records: records.items.filter(record => record.status.phase === 'Available')
    //   })
    // })
    // .catch(error => console.log(error))

    // fetch('/allPersistentVolumes')
    //   .then(response => response.json())
    //   .then(records => {
    //     this.setState({
    //       records: records.items.filter(record => record.status.phase === 'Available')
    //     })
    //   })
    //   .catch(error => console.log(error))
  }

  renderListing () {
    const recordList = []
    this.state.records.map(record => {
      return recordList.push(<li key={record.metadata.name}>{record.metadata.name}</li>)
    })

    return recordList
  }

  render () {
    return (
      <div>
        <h1 className='header'>XkOps - Unclaimed Volumes</h1>
        <div className='table-container'>
          <VolumeTable records={this.state.records} />
        </div>
      </div>
    )
  }
}

export default UnclaimedVolumes
