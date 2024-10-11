import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Card, Avatar, Row, Col } from "antd";
import { useNavigate } from "react-router-dom";
import axios from 'axios';
const { Meta } = Card;

const CardContainer = styled.div`
  .Card-row-parent {
    margin: 5%;
  }
  .Card_title {    
    color: rgb(2, 57, 39);
    font-weight: bolder;
    padding-bottom: 1em;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 1rem;
  }
  .Card_description {
    color: rgb(96, 121, 113);
    font-size: 14px;
    text-align: left;
  }    
  .Section3 {
    margin-top: 5%;
    display: flex;
    justify-content: center;
  }
  .Section3-text {
    font-size: .875rem;
    flex-grow: 1;
    font-family: 'Space Grotesk', sans-serif;
  }
  .Section3-text2 {
    font-size: 1.3rem;
    font-weight: bold;
    color: #538ACA;
  }
`;

const WorkflowListComponent = () => {
  // const BACKENDURL = process.env.REACT_APP_BACKEND_URL;
  // console.log(BACKENDURL)
  const navigate = useNavigate(); 
  const [cardData, setCardData] = useState([]);
  const [error, setError] = useState(null);

  const fetchData = async () => {
    try {
        const response = await axios.get("/api/get_savings", {
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
        });

        // No need to check for response.ok as Axios throws an error for HTTP status codes outside the range of 2xx
        const result = response.data; // Axios automatically parses the JSON response

        // Extract unclaimedVolumes, requestSizing, abandonedWorkload, and nodeTurndown from the response
        const { unclaimedVolumes, requestSizing, abandonedWorkload, nodeTurndown } = result;

        // Prepare the data for the cards
        const updatedData = [
            {
                title: "Manage unclaimed volumes",
                description: "Delete volumes that are not used by any pod. Detected volume can be deleted",
                cost: `$${unclaimedVolumes.value.toFixed(2)}`,
            },
            {
                title: "Manage underutilized nodes",
                description: "A user will be recommended for the nodes cpu and memory utilization",
                cost: `$${nodeTurndown.value.toFixed(2)}`,
            },
            {
                title: "Manage abandoned workloads",
                description: "Over-provisioned containers provide an opportunity to lower requests and save money.",
                cost: `$${abandonedWorkload.value.toFixed(2)}`,
            },
            {
                title: "Right size container requests",
                description: "Detect pods that don't send or receive a meaningful rate of network traffic.",
                cost: `$${requestSizing.value.toFixed(2)}`,
            },
        ];

        // Set the updated data in state
        setCardData(updatedData);

    } catch (error) {
        // Axios error contains response, so you can log it
        console.error("Error fetching data:", error.response || error.message);
        setError(error.message); // Set the error message to state
    }
};

  useEffect(() => {
    fetchData(); // Fetch data immediately when component mounts

    const intervalId = setInterval(() => {
      fetchData();
    }, 60000); // Fetch data every 60 seconds

    return () => clearInterval(intervalId); // Cleanup interval on component unmount
  }, []);

  const handleCardClick = (title) => {
    if (title === "Manage unclaimed volumes") {
      navigate('/unclaimedpvs');
    } else if (title === "Manage underutilized nodes") {
      navigate('/underutilizednodes');
    } else if (title === "Right size container requests") {
      navigate('/rightsizecontainer');
    } else if (title === "Manage abandoned workloads") {
      navigate('/abandonendworkload');
    } else {
      console.log("No matching route for this title.");
    }
  };

  return (
    <CardContainer>
      <div className='Card-row-parent'>
        <Row justify="start" gutter={[16, 16]}>
          {cardData.map((Element, index) => (
            <Col xs={24} 
            sm={24} 
            md={12}  // Adjusted for 2 cards per row on medium screens
            lg={6}   // 3 cards per row on large screens
            key={index}>
              <Card 
                style={{ width: "100%", cursor: 'pointer' }}
                onClick={() => handleCardClick(Element.title)}
              >
                <div className="Card_title">
                  {Element.title}
                </div>
                <div className="Card_description">
                  {Element.description}
                </div>
                <div className='Section3'>
                  <Meta
                    avatar={<Avatar src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSVtCGm2tcKUzuseqNNH6g1izM-rMJDc-lIVg&s" />}
                  />
                  <div className='Section3-text'>Kubernetes Insight</div>
                  <div className='Section3-text2'>{Element.cost}</div>
                </div>
              </Card>
            </Col>
          ))}
        </Row>
      </div>
    </CardContainer>
  );
};

export default WorkflowListComponent;
