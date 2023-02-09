import React from "react";
import "./VolumeTable.css";

const VolumeTable = props => {
  return (
    <table className="volume-table">
      <thead>
        <tr>
          <th>Serial Number</th>
          <th>Volume Name</th>
          <th>Volume Status</th>
        </tr>
      </thead>
      <tbody>
        {props.records.map((record, index) => (
          <tr key={record.metadata.name}>
            <td>{index + 1}</td>
            <td>{record.metadata.name}</td>
            <td>{record.status.phase}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default VolumeTable;
