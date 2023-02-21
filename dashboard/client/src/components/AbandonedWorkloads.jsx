import React, { Component } from 'react'

class AbandonedWorkloads extends Component {
  constructor (props) {
    super(props)
    this.state = {
      records: []
    }
  }

  componentDidMount () {
    fetch('http://a06fc35aeb33f46e3bf19742538467b1-1092220675.ap-southeast-1.elb.amazonaws.com/model/savings/abandonedWorkloads')
      .then(response => response.json())
      .then(records => {
        this.setState({
          records
        })
      })
      .catch(error => console.log(error))
  }

  renderListing () {
    const recordList = []
    this.state.records.map(record => {
      return recordList.push(<li key={record.pod}>{record.pod}</li>)
    })

    return recordList
  }

  render () {
    return (
      <div>
        {this.renderListing()}
      </div>
    )
  }
}

export default AbandonedWorkloads
