import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Table, Button, message } from 'antd';
import ReplicaResizeModal from './ReplicaResizeModal';

const columns = (handleDelete, handleResize) => [
  {
    title: 'Name',
    dataIndex: 'pod',
    key: 'pod',
  },
  {
    title: 'Namespace',
    dataIndex: 'namespace',
    key: 'namespace',
  },
  {
    title: 'Kind',
    dataIndex: 'kind',
    key: 'kind',
  },
  {
    title: 'Monthly Savings',
    dataIndex: 'monthlySavings',
    render: (value) => `$${value.toFixed(3)}`,
  },
  {
    title: 'Resize Replicas',
    key: 'resizeReplicas',
    render: (text, record) => {
      const isDisabled = record.kind === 'pod';
      return (
        <Button
          style={isDisabled ? {} : { background: '#538ACA', color: 'white' }}
          onClick={() => handleResize(record)}
          disabled={isDisabled}
        >
          Resize Replicas
        </Button>
      );
    },
  },
  {
    title: 'Action',
    key: 'action',
    render: (text, record) => (
      <Button style={{ background: '#538ACA', color: "white" }} type="danger" onClick={() => handleDelete(record)}>
        Delete
      </Button>
    ),
  },
];

const TableContainer = styled.div`
  .Table-row-parent {
    margin: 5%;
  }
`;

const AbandonendWorkflowTable = () => {
  const BACKENDURL = process.env.REACT_APP_BACKEND_URL;
  const [data, setData] = useState([]);
  const [loadingApi, setLoadingApi] = useState(true);
  const [error, setError] = useState(null);
  const [modalVisible, setModalVisible] = useState(false);
  const [currentRecord, setCurrentRecord] = useState(null);
  const [currentReplicas, setCurrentReplicas] = useState(0); // State to hold the current replicas

  useEffect(() => {
    fetch("/api/abandoned_workloads", {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        const uniqueDataMap = new Map();
        const separateData = [];

        data.forEach((item) => {
          const kind = item.owners?.[0]?.kind || '';
          const name = item.owners?.[0]?.name || '';

          if (kind === '' || name === '') {
            separateData.push({
              key: `${item.pod}-${item.namespace}`,
              pod: item.pod,
              namespace: item.namespace,
              kind: kind || 'pod',
              monthlySavings: item.monthlySavings,
            });
          } else {
            const uniqueKey = `${kind}-${name}`;
            if (!uniqueDataMap.has(uniqueKey)) {
              uniqueDataMap.set(uniqueKey, {
                key: uniqueKey,
                pod: name,
                namespace: item.namespace,
                kind: kind,
                monthlySavings: item.monthlySavings,
              });
            }
          }
        });

        const combinedData = [...Array.from(uniqueDataMap.values()), ...separateData];

        setData(combinedData);
        setLoadingApi(false);
      })
      .catch((error) => {
        setError(error);
        setLoadingApi(false);
      });
  }, []);

  const handleDelete = (record) => {
    const { pod, namespace, kind } = record;
    if (kind === "deployment") {
      const deploymentName = pod;
      fetch("/api/delete_deployment", {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name: deploymentName, namespace: namespace }),
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error('Failed to delete the deployment');
          }
          return response.json();
        })
        .then(() => {
          message.success(`Deployment ${deploymentName} deleted successfully.`);
          setData((prevData) => prevData.filter((item) => item.pod !== pod));
        })
        .catch((error) => {
          message.error(`Error: ${error.message}`);
        });
    } else {
      fetch("/api/delete_pod", {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name: pod, namespace: namespace }),
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error('Failed to delete the pod');
          }
          return response.json();
        })
        .then(() => {
          message.success(`Pod ${pod} deleted successfully.`);
          setData((prevData) => prevData.filter((item) => item.pod !== pod));
        })
        .catch((error) => {
          message.error(`Error: ${error.message}`);
        });
    }
  };

  const handleResize = (record) => {
    const { pod, namespace } = record;

    // Fetch the current number of replicas for the selected deployment
    fetch(`/api/replicas/${namespace}/${pod}`)
      .then((response) => {
        if (!response.ok) {
          throw new Error('Failed to fetch current replicas');
        }
        return response.json();
      })
      .then((data) => {
        setCurrentReplicas(data.replicas);
        setCurrentRecord(record); // Set the current record to show in modal
        setModalVisible(true); // Show the modal when resize button is clicked
      })
      .catch((error) => {
        message.error(`Error: ${error.message}`);
      });
  };

  const handleModalSubmit = (replicas) => {
    if (replicas > currentReplicas) {
      message.warning(`Please enter fewer replicas than the current number (${currentReplicas}).`);
      return; // Don't proceed if user enters more replicas than current
    }

    const { pod, namespace } = currentRecord;

    fetch(`/api/resize_replicas?name=${pod}&namespace=${namespace}&replicas=${replicas}`, {
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error('Failed to resize replicas');
        }
        return response.json();
      })
      .then(() => {
        message.success(`Replicas resized successfully.`);
        setModalVisible(false); // Close the modal
      })
      .catch((error) => {
        message.error(`Error: ${error.message}`);
      });
  };

  return (
    <TableContainer>
      <div className="Table-row-parent">
        <Table
          columns={columns(handleDelete, handleResize)}
          dataSource={data}
          loading={loadingApi}
        />
        {currentRecord && (
          <ReplicaResizeModal
            visible={modalVisible}
            onClose={() => setModalVisible(false)}
            onSubmit={handleModalSubmit}
            record={currentRecord}
          />
        )}
      </div>
    </TableContainer>
  );
};

export default AbandonendWorkflowTable;
