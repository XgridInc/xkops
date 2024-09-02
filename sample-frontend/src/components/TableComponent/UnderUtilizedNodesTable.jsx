import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Table, Button, message } from 'antd';

const columns = () => [
  {
    title: 'Node Name',
    dataIndex: 'name',
    key: 'name',
  },
  {
    title: 'Node Cpu Cores',
    dataIndex: 'cpuCores',
    key: 'cpuCores',
  },
  {
    title: 'Total Costs',
    dataIndex: 'totalCost',
    key: 'totalCost',
    render: (value) => `$${value.toFixed(2)}`,
  },

];

const TableContainer = styled.div`
  .Table-row-parent {
    margin: 5%;
  }
`;

const UnderUtilizedNodesTable= () => {
  const BACKENDURL = process.env.REACT_APP_BACKEND_URL;
  const [selectedRowKeys, setSelectedRowKeys] = useState([]);
  const [data, setData] = useState([]);
  const [loadingApi, setLoadingApi] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(`${BACKENDURL}/nodes`)
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
          cpuCores: item.cpuCores,
          totalCost: item.totalCost,
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
          columns={columns()}
          dataSource={data}
          loading={loadingApi}
        />
      </div>
    </TableContainer>
  );
};

export default UnderUtilizedNodesTable;
