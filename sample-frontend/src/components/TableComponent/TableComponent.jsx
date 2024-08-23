import React, { useState } from 'react';
import styled from 'styled-components';
import {  Table, Button, Flex } from "antd";


const columns = [
    {
      title: 'Name',
      dataIndex: 'name',
    },
    {
      title: 'Age',
      dataIndex: 'age',
    },
    {
      title: 'Address',
      dataIndex: 'address',
    },
  ];
  const dataSource = Array.from({
    length: 46,
  }).map((_, i) => ({
    key: i,
    name: `Edward King ${i}`,
    age: 32,
    address: `London, Park Lane no. ${i}`,
  }));

const TableContainer = styled.div`
  .Table-row-parent {
    margin: 5%;
  }
//   .ant-table-wrapper .ant-table {
//   background-color: #E8EDF2;
//   }
//   .ant-table-thead .ant-table-cell {
//   background-color: #E8EDF2;
// }

`;

const TableComponent = () => {
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const [loading, setLoading] = useState(false);
    const start = () => {
      setLoading(true);
      setTimeout(() => {
        setSelectedRowKeys([]);
        setLoading(false);
      }, 1000);
    };
    const onSelectChange = (newSelectedRowKeys) => {
      console.log('selectedRowKeys changed: ', newSelectedRowKeys);
      setSelectedRowKeys(newSelectedRowKeys);
    };
    const rowSelection = {
      selectedRowKeys,
      onChange: onSelectChange,
    };
    const hasSelected = selectedRowKeys.length > 0;

  return (
    <TableContainer>
        <div className='Table-row-parent'>
            <Flex gap="middle" vertical>
            {/* <Flex align="center" gap="middle">
                <Button type="primary" onClick={start} disabled={!hasSelected} loading={loading}>
                Delete
                </Button>
                {hasSelected ? `Selected ${selectedRowKeys.length} items` : null}
                </Flex> */}
            {/* <Table rowSelection={rowSelection} columns={columns} dataSource={dataSource} color={"blue"} headerColor={"red"}/> */}
            <Table rowSelection={rowSelection} columns={columns} dataSource={dataSource} />
            </Flex>
        </div>
        
    </TableContainer>
  );
};

export default TableComponent;
