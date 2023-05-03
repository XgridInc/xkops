// Copyright (c) 2023, Xgrid Inc, https://xgrid.co

// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
