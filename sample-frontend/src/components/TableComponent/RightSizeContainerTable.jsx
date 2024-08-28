import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Table, Button, message } from 'antd';

const columns = (handleResizeCpu,handleResizeMemory) => [
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
    // render: (value) => `$${value.toFixed(5)}`,
  },
  {
    title: 'Recommended CPU',
    dataIndex: 'cpu',
    key: 'cpu',
    // render: (value) => `$${value.toFixed(5)}`,
  },
  {
    title: 'Recommended Memory',
    dataIndex: 'memory',
    key: 'memory',
    // render: (value) => `$${value.toFixed(5)}`,
  },
  {
    title: 'Monthly Savings',
    dataIndex: 'monthlySavings',
    key: 'monthlySavings',
    // render: (value) => `$${value.toFixed(3)}`,
  },
  {
    title: 'Resize CPU',
    key: 'Resize CPU',
    render: (text, record) => (
      <Button style={{background:'#538ACA',color:"white"}} type="danger" 
      onClick={() => handleResizeCpu(record)}
      >
        Resize CPU
      </Button>
    ),
  },
  {
    title: 'Resize Memory',
    key: 'Resize Memory',
    render: (text, record) => (
      <Button style={{background:'#538ACA',color:"white"}} type="danger" 
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
  const [selectedRowKeys, setSelectedRowKeys] = useState([]);
  const [data, setData] = useState([]);
  const [loadingApi, setLoadingApi] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://172.19.49.240:5000/sizing_v2')
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
  }, []);

  const handleDelete = (record) => {
      const pvName = record.name;
      fetch('http://172.19.49.240:5000/delete_pv', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ pv_name: pvName }),
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error('Failed to delete the PV');
          }
          return response.json();
        })
        .then(() => {
          message.success(`PV ${pvName} deleted successfully.`);
          setData((prevData) => prevData.filter((item) => item.name !== pvName));
        })
        .catch((error) => {
          message.error(`Error: ${error.message}`);
        });
    
  };
  const handleResizeMemory = (record) => {
  console.log("Records are ",record)
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

export default RightSizeContainerTable;
