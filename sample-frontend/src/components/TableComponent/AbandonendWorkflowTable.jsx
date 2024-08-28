import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Table, Button, message } from 'antd';

const columns = (handleDelete) => [
  {
    title: 'Pod Name',
    dataIndex: 'pod',
    key: 'pod',
  },
  {
    title: 'Pod Namespace',
    dataIndex: 'namespace',
    key: 'namespace',
  },
  {
    title: 'Monthly Savings',
    dataIndex: 'monthlySavings',
    key: 'monthlySavings',
    render: (value) => `$${value.toFixed(3)}`,
  },
  {
    title: 'Action',
    key: 'action',
    render: (text, record) => (
      <Button style={{background:'#538ACA',color:"white"}} type="danger" onClick={() => handleDelete(record)}>
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
  const [selectedRowKeys, setSelectedRowKeys] = useState([]);
  const [data, setData] = useState([]);
  const [loadingApi, setLoadingApi] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://172.19.49.240:5000/abandoned_workloads')
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        const transformedData = data.map((item, index) => ({
          key: index,
          pod: item.pod,
          namespace: item.namespace,
          monthlySavings: item.monthlySavings,
          owners: item.owners,
        }));

        setData(transformedData);
        setLoadingApi(false);
      })
      .catch((error) => {
        setError(error);
        setLoadingApi(false);
      });
  }, []);

  const handleDelete = (record) => {
    const { pod, namespace, owners } = record;

    if (owners && owners.length > 0 && owners[0].kind && owners[0].name) {
      const deploymentName = owners[0].name;
      fetch('http://172.19.49.240:5000/delete_deployment', {
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
      fetch('http://172.19.49.240:5000/delete_pod', {
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

//   const handleDeleteSelected = () => {
//     if (selectedRowKeys.length === 0) {
//       message.warning('Please select at least one item to delete.');
//       return;
//     }

//     const selectedItems = data.filter((item) => selectedRowKeys.includes(item.key));
//     selectedItems.forEach((record) => handleDelete(record));

//     setSelectedRowKeys([]); // Clear selected keys after deletion
//   };

  const onSelectChange = (newSelectedRowKeys) => {
    setSelectedRowKeys(newSelectedRowKeys);
  };

//   const rowSelection = {
//     selectedRowKeys,
//     onChange: onSelectChange,
//   };

  return (
    <TableContainer>
      <div className="Table-row-parent">
        {/* <Button
          type="danger"
          onClick={handleDeleteSelected}
          disabled={selectedRowKeys.length === 0}
          style={{background:'#538ACA',color:"white", marginBottom:"1rem"}}
        >
          Delete Selected
        </Button>
        <span style={{ marginLeft: 8 }}>
          {selectedRowKeys.length > 0 ? `Selected ${selectedRowKeys.length} items` : ''}
        </span> */}
        <Table
        //   rowSelection={rowSelection}
          columns={columns(handleDelete)}
          dataSource={data}
          loading={loadingApi}
        />
      </div>
    </TableContainer>
  );
};

export default AbandonendWorkflowTable;
