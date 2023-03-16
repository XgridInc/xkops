import React, { Component } from 'react'
import VolumeTable from './VolumeTable'
import './VolumeTable.css'
import './unclaimedVolume.css'

// A React class component that displays a list of unclaimed volumes and a table of details about them.
class UnclaimedVolumes extends Component {

    // Constructor function that initializes the component's state with an empty array for the list of unclaimed volumes.
  constructor (props) {
    super(props)
    this.state = {
      records: []
    }
  }

    // Lifecycle method that fetches data from the server when the component mounts, and updates the component's state with the unclaimed volumes.
  async componentDidMount () {
    fetch('/allPersistentVolumes')
      .then(response => response.json())
      .then(records => {
        this.setState({
          records: records.items.filter(record => record.status.phase === 'Available')
        })
      })
      .catch(error => console.log(error))
  }

    // Renders the list of unclaimed volumes as an unordered list.
  renderListing () {
    const recordList = []
    this.state.records.map(record => {
      return recordList.push(<li key={record.metadata.name}>{record.metadata.name}</li>)
    })

    return recordList
  }

    // Renders the component's content, including the header and table of unclaimed volumes.
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
