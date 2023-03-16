import React, { useState } from 'react'
import './VolumeTable.css'
import DeleteModal from './DeleteModal'

const VolumeTable = props => {
  // Adding initial state using useState hook for showModal and recordName variables.
  const [showModal, setShowModal] = useState(false)
  const [recordName, setRecordName] = useState('')

  // This function toggles the visibility of the DeleteModal component and sets the record name to be deleted.
  const toggleModal = (recordName = '') => {
    setShowModal(!showModal)
    setRecordName(recordName)
  }

  // This function handles the deletion of a persistent volume by making an API call to the backend server.
  const handleDelete = () => {
    fetch('/robusta', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        action_name: 'delete_persistent_volume',
        action_params: {
          name: recordName,
          namespace: 'default'
        }
      })
    })
      .then(response => {
        if (response.ok) {
          console.log(response)
          toggleModal()
        } else {
          // API call failed
          throw new Error('API call failed')
        }
      })
      .catch(error => {
        // Handle API call error
        console.log('error here')
        console.error(error)
      })
  }

  const handleCancel = () => {
    toggleModal()
  }

  // The code renders a table with volume records
  // and a delete button for each record.
  // It also conditionally renders a delete
  // confirmation modal when the user clicks on the delete button.

  return (
    <>
      <table className='volume-table'>
        <thead>
          <tr>
            <th>Serial Number</th>
            <th>Volume Name</th>
            <th>Volume Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {props.records.map((record, index) => (
            <tr key={record.metadata.name}>
              <td>{index + 1}</td>
              <td>{record.metadata.name}</td>
              <td>{record.status.phase}</td>
              <td>
                <button onClick={() => toggleModal(record.metadata.name)}>Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {showModal && (
        <DeleteModal
          showModal={showModal}
          recordName={recordName}
          handleDelete={handleDelete}
          handleCancel={handleCancel}
        />
      )}
    </>
  )
}

export default VolumeTable
