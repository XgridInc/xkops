import React,{useState, useEffect} from 'react';
import styled from 'styled-components';
import { Card, Avatar, Row, Col } from "antd";
import { useNavigate } from "react-router-dom";

const { Meta } = Card;

const data = [
  {
    title: "Manage unclaimed volumes",
    description: "Delete volumes that are not used by any pod. Detected volume can be deleted",
    cost: "$23",
  },
  {
    title: "Manage underutilized nodes",
    description: "Turn down or resize nodes with low memory and CPU utilization. A user will be recommended for the nodes cpu and memory utilization",
    cost: "$40",
  },
  {
    title: "Right size container requests",
    description: "Detect pods that don't send or receive a meaningful rate of network traffic.",
    cost: "$2",
  },
  {
    title: "Manage abandoned workloads",
    description: "Over-provisioned containers provide an opportunity to lower requests and save money. Under-provisioned containers may cause CPU throttling or memory-based evictions.",
    cost: "$43",
  },
];

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
  const navigate = useNavigate(); 
  const [containerRequest, setcontainerRequest] = useState(null);
  const [error, setError] = useState(null);

  const fetchData = async () => {
    try {
      const response = await fetch('http://127.0.0.1:9090/model/savings/requestSizingV2?algorithmCPU=max&algorithmRAM=max&filter=&targetCPUUtilization=0.65&targetRAMUtilization=0.65&window=48h&sortByOrder=descending&offset=0&limit=25');
      if (!response.ok) {
        throw new Error(`Error: ${response.statusText}`);
      }
      const result = await response.json();
      console.log(result.TotalMonthlySavings)
      const formattedSavings = `$${result.TotalMonthlySavings.toFixed(2)}`
      setcontainerRequest(formattedSavings);
    } catch (error) {
      setError(error.message);
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
          {data.map((Element, index) => (
            <Col span={8} key={index}>
              <Card 
                style={{ width: 500, cursor: 'pointer' }}
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
