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
