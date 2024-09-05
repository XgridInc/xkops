import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Table, Button, message } from 'antd';

const columns = (handleDelete) => [
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
  const BACKENDURL = process.env.REACT_APP_BACKEND_URL;
  const [selectedRowKeys, setSelectedRowKeys] = useState([]);
  const [data, setData] = useState([]);
  const [loadingApi, setLoadingApi] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(`${BACKENDURL}/abandoned_workloads`)
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
            // If kind or name is empty, push it to separateData array
            separateData.push({
              key: `${item.pod}-${item.namespace}`,
              pod: item.pod,
              namespace: item.namespace,
              kind: kind || 'pod', // Display 'N/A' if kind is empty
              monthlySavings: item.monthlySavings,
            });
          } else {
            const uniqueKey = `${kind}-${name}`;
  
            if (!uniqueDataMap.has(uniqueKey)) {
              uniqueDataMap.set(uniqueKey, {
                key: uniqueKey,
                pod: name, // Set pod to the name from owners when duplicates are found
                namespace: item.namespace,
                kind: kind,
                monthlySavings: item.monthlySavings,
              });
            }
          }
        });
  
        // Combine unique data with the separate data entries
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
    console.log("owners is ", record)
    if (kind == "deployment") {
      const deploymentName = pod;
      fetch(`${BACKENDURL}/delete_deployment`, {
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
      fetch(`${BACKENDURL}/delete_pod`, {
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
