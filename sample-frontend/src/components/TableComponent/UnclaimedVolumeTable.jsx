import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Table, Button, message } from 'antd';

const columns = (handleDelete) => [
  {
    title: 'Unclaimed Volume Name',
    dataIndex: 'name',
    key: 'name',
  },
  {
    title: 'Provider',
    dataIndex: 'provider',
    key: 'provider',
  },
  {
    title: 'Monthly Costs',
    dataIndex: 'monthlyCost',
    key: 'monthlyCost',
    render: (value) => `$${value.toFixed(5)}`,
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

const UnclaimedVolumeTable = () => {
  const [selectedRowKeys, setSelectedRowKeys] = useState([]);
  const [data, setData] = useState([]);
  const [loadingApi, setLoadingApi] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://172.19.49.240:5000/unclaimed_volumes')
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        const transformedData = data.map((item, index) => ({
          key: index,
          name: item.name,
          provider: item.provider,
          monthlyCost: item.monthlyCost,
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

export default UnclaimedVolumeTable;
