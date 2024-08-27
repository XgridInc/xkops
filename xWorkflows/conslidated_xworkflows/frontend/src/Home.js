import React from 'react';
import styled from 'styled-components';

// Styled components
const Container = styled.div`
  padding: 20px;
  max-width: 800px;
  margin: auto;
`;

const Title = styled.h1`
  color: #333;
  margin-bottom: 20px;
`;

const Paragraph = styled.p`
  font-size: 18px;
  line-height: 1.6;
  color: #666;
`;

const Home = () => {
  return (
    <Container>
      <Title>Welcome to Our Application</Title>
      <Paragraph>
        This is the home page of our application where you can find various features and insights related to managing your cloud resources.
      </Paragraph>
      <Paragraph>
        Navigate through different sections using the menu above to learn more about our offerings, get in touch with us, or view the unclaimed volumes in your Kubernetes clusters.
      </Paragraph>
      <Paragraph>
        Explore and make the most of our tools to optimize your infrastructure and reduce unnecessary costs.
      </Paragraph>
    </Container>
  );
}

export default Home;
