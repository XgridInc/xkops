import React from "react";
import "./DeleteModal.css";

const DeleteModal = props => {
  return (
    <div className={props.showModal ? "delete-modal-container show" : "delete-modal-container"}>
      <div className="delete-modal">
        <div className="delete-modal-header">
          <h3>Confirm Delete</h3>
        </div>
        <div className="delete-modal-body">
          <p>Are you sure you want to delete the volume: <b>{props.recordName}</b>?</p>
        </div>
        <div className="delete-modal-footer">
          <button onClick={props.handleCancel}>Cancel</button>
          <button onClick={props.handleDelete}>Delete</button>
        </div>
      </div>
    </div>
  );
};

export default DeleteModal;
