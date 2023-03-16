import React from 'react'
import './DeleteModal.css'

// The DeleteModal is a functional React component that displays
// a modal dialog box for confirming the deletion of a volume.
// It takes in props such as showModal, recordName, handleCancel,
// and handleDelete, and renders the modal using CSS classes and HTML elements.

const DeleteModal = props => {
  return (
    <div className={props.showModal ? 'delete-modal-container show' : 'delete-modal-container'}>
      <div className='delete-modal'>
        <div className='delete-modal-header'>
          <h3>Confirm Delete</h3>
        </div>
        <div className='delete-modal-body'>
          <p>Are you sure you want to delete the volume: <b>{props.recordName}</b>?</p>
        </div>
        <div className='delete-modal-footer'>
          <button onClick={props.handleCancel}>Cancel</button>
          <button onClick={props.handleDelete}>Delete</button>
        </div>
      </div>
    </div>
  )
}

export default DeleteModal
