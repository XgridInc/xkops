import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Table, Button, message } from 'antd';

const columns = (handleResizeCpu, handleResizeMemory) => [
  {
    title: 'Container Name',
    dataIndex: 'containerName',
    key: 'containerName',
  },
  {
    title: 'Kind',
    dataIndex: 'controllerKind',
    key: 'controllerKind',
  },
  {
    title: 'Resource Name',
    dataIndex: 'controllerName',
    key: 'controllerName',
  },
  {
    title: 'Recommended CPU',
    dataIndex: 'cpu',
    key: 'cpu',
  },
  {
    title: 'Recommended Memory',
    dataIndex: 'memory',
    key: 'memory',
  },
  {
    title: 'Monthly Savings',
    dataIndex: 'monthlySavings',
    key: 'monthlySavings',
  },
  {
    title: 'Resize CPU',
    key: 'resizeCpu',
    render: (text, record) => (
      <Button
        style={{ background: '#538ACA', color: 'white' }}
        onClick={() => handleResizeCpu(record)}
      >
        Resize CPU
      </Button>
    ),
  },
  {
    title: 'Resize Memory',
    key: 'resizeMemory',
    render: (text, record) => (
      <Button
        style={{ background: '#538ACA', color: 'white' }}
        onClick={() => handleResizeMemory(record)}
      >
        Resize Memory
      </Button>
    ),
  },
];

const TableContainer = styled.div`
  .Table-row-parent {
    margin: 5%;
  }
`;

const RightSizeContainerTable = () => {
  const [data, setData] = useState([]);
  const [loadingApi, setLoadingApi] = useState(true);
  const [error, setError] = useState(null);
  const BACKENDURL = process.env.REACT_APP_BACKEND_URL;

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = () => {
    fetch(`${BACKENDURL}/sizing_v2`)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        const transformedData = data.map((item, index) => ({
          key: index,
          containerName: item.containerName,
          controllerKind: item.controllerKind,
          controllerName: item.controllerName,
          namespace: item.namespace,
          recommendedRequest: item.recommendedRequest,
          cpu: item.recommendedRequest.cpu,
          memory: item.recommendedRequest.memory,
          monthlySavings: item.monthlySavings.total,
        }));

        setData(transformedData);
        setLoadingApi(false);
      })
      .catch((error) => {
        setError(error);
        setLoadingApi(false);
      });
  };

  const handleResizeCpu = (record) => {
    const { controllerKind, controllerName, namespace, recommendedRequest } = record;
    const apiUrl =
      controllerKind === 'deployment'
        ? `${BACKENDURL}/update_deployment_cpu`
        : `${BACKENDURL}/update_pod_cpu`;

    const body = {
      name: controllerName,
      namespace: namespace,
      updateCpuRequest: recommendedRequest.cpu,
    };

    fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error('Failed to resize CPU');
        }
        return response.json();
      })
      .then(() => {
        message.success(`CPU resized successfully for ${controllerName}.`);
        // Trigger a re-fetch of the data to update the table
        fetchData();
      })
      .catch((error) => {
        message.error(`Error: ${error.message}`);
      });
  };

  const handleResizeMemory = (record) => {
    const { controllerKind, controllerName, namespace, recommendedRequest } = record;
    const apiUrl =
      controllerKind === 'deployment'
        ? `${BACKENDURL}/update_deployment_memory`
        : `${BACKENDURL}/update_pod_memory`;

    const body = {
      name: controllerName,
      namespace: namespace,
      updateMemoryRequest: recommendedRequest.memory,
    };

    fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error('Failed to resize Memory');
        }
        return response.json();
      })
      .then(() => {
        message.success(`Memory resized successfully for ${controllerName}.`);
        // Trigger a re-fetch of the data to update the table
        fetchData();
      })
      .catch((error) => {
        message.error(`Error: ${error.message}`);
      });
  };

  return (
    <TableContainer>
      <div className="Table-row-parent">
        <Table
          columns={columns(handleResizeCpu, handleResizeMemory)}
          dataSource={data}
          loading={loadingApi}
        />
      </div>
    </TableContainer>
  );
};

export default RightSizeContainerTable;

