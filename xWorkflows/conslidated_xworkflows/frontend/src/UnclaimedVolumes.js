import React, { useState, useEffect } from 'react';
import styled from 'styled-components';

// Styled components
const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
`;

const Title = styled.h1`
  color: #0038A8; /* Dark blue */
  margin-bottom: 20px;
`;

const Summary = styled.div`
  margin-bottom: 20px;
  text-align: center;
`;

const SummaryTitle = styled.h2`
  color: #0038A8; /* Dark blue */
  margin-bottom: 10px;
`;

const SummaryText = styled.p`
  font-size: 16px;
  color: #2C3E50; /* Darker blue-gray */
`;

const Table = styled.table`
  border-collapse: collapse;
  width: 80%;
`;

const TableHeader = styled.th`
  background-color: #0038A8; /* Dark blue */
  color: #E9F0F5; /* Light blue */
  padding: 10px;
  text-align: left;
`;

const TableRow = styled.tr`
  &:nth-child(even) {
    background-color: #F0F4F8; /* Very light blue */
  }
`;

const TableCell = styled.td`
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
`;

const Loading = styled.p`
  font-size: 18px;
  color: #007bff; /* Bootstrap blue */
`;

const Error = styled.p`
  font-size: 18px;
  color: red;
`;

const FilterContainer = styled.div`
  margin-bottom: 20px;
`;

const FilterSelect = styled.select`
  padding: 10px;
  font-size: 16px;
  border: 1px solid #ddd;
  border-radius: 5px;
  cursor: pointer;
  
  &:hover {
    border-color: #0038A8; /* Dark blue */
  }
`;

const DeleteButton = styled.button`
  background-color: #FF6F61; /* Coral */
  color: white;
  border: none;
  border-radius: 5px;
  padding: 5px 10px;
  cursor: pointer;
  font-size: 14px;

  &:hover {
    background-color: #FF4C4C; /* Darker coral */
  }
`;

const UnclaimedVolumes = () => {
  const [volumes, setVolumes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [count, setCount] = useState(0);
  const [filter, setFilter] = useState('today'); // Default filter

  // Function to fetch data
  const fetchData = (window) => {
    setLoading(true);
    fetch(`http://localhost:9090/model/savings/unclaimedVolumes?window=${window}`)
      .then((response) => response.json())
      .then((data) => {
        if (data.code === 200) {
          setVolumes(data.data.volumes);
          setCount(data.data.count);
        }
        setLoading(false);
      })
      .catch((error) => {
        setError(error);
        setLoading(false);
      });
  };

  useEffect(() => {
    // Fetch data initially with default filter
    fetchData(filter);
    
    // Set up interval to fetch data every 30 seconds
    const intervalId = setInterval(() => fetchData(filter), 30000); // Adjust the interval as needed

    // Clean up the interval on component unmount
    return () => clearInterval(intervalId);
  }, [filter]);

  const handleFilterChange = (event) => {
    const newFilter = event.target.value;
    setFilter(newFilter);
    fetchData(newFilter); // Fetch new data based on selected filter
  };

  const handleDelete = (volumeName) => {
    fetch('http://172.18.0.3:30007/delete_pv', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ pv_name: volumeName }),
    })
      .then(response => response.json())
      .then(data => {
        if (data.response.success) {
          alert(`PV ${volumeName} deletion initiated`);
          fetchData(filter); // Refresh the list after deletion
        } else {
          alert(`Failed to delete PV ${volumeName}: ${data.response.msg}`);
        }
      })
      .catch((error) => {
        alert(`Error deleting PV ${volumeName}: ${error.message}`);
      });
  };

  if (loading) return <Loading>Loading...</Loading>;
  if (error) return <Error>Error loading data: {error.message}</Error>;

  return (
    <Container>
      <Title>Unclaimed Volumes</Title>
      <Summary>
        <SummaryTitle>{count} Unclaimed Volumes</SummaryTitle>
        <SummaryText>
          Examine volumes that aren't currently linked to any volume claims. You may want to delete them to cut costs.
        </SummaryText>
      </Summary>
      <FilterContainer>
        <FilterSelect value={filter} onChange={handleFilterChange}>
          <option value="today">Today</option>
          <option value="yesterday">Yesterday</option>
          <option value="week">Week to date</option>
          <option value="month">Month to date</option>
          <option value="lastweek">Last week</option>
          <option value="lastmonth">Last month</option>
          <option value="24h">Last 24h</option>
          <option value="48h">Last 48h</option>
          <option value="7d">Last 7 days</option>
          <option value="30d">Last 30 days</option>
          <option value="60d">Last 60 days</option>
          <option value="90d">Last 90 days</option>
        </FilterSelect>
      </FilterContainer>
      <Table>
        <thead>
          <tr>
            <TableHeader>Volume Name</TableHeader>
            <TableHeader>Monthly Cost</TableHeader>
            <TableHeader>Category</TableHeader>
            <TableHeader>Provider</TableHeader>
            <TableHeader>Account</TableHeader>
            <TableHeader>Service</TableHeader>
            <TableHeader>Cluster</TableHeader>
            <TableHeader>Action</TableHeader> {/* New column for actions */}
          </tr>
        </thead>
        <tbody>
          {volumes.map((volume, index) => (
            <TableRow key={index}>
              <TableCell>{volume.volumeName}</TableCell>
              <TableCell>{volume.monthlyCost.toFixed(2)}</TableCell>
              <TableCell>{volume.properties.category}</TableCell>
              <TableCell>{volume.properties.provider}</TableCell>
              <TableCell>{volume.properties.account}</TableCell>
              <TableCell>{volume.properties.service}</TableCell>
              <TableCell>{volume.properties.cluster}</TableCell>
              <TableCell>
                <DeleteButton onClick={() => handleDelete(volume.volumeName)}>
                  Delete PV
                </DeleteButton>
              </TableCell>
            </TableRow>
          ))}
        </tbody>
      </Table>
    </Container>
  );
};

export default UnclaimedVolumes;
