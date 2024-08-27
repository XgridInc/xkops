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

const About = () => {
  return (
    <Container>
      <Title>About Us</Title>
      <Paragraph>
        Welcome to our application! We provide insights into unclaimed volumes and their costs within your Kubernetes clusters.
      </Paragraph>
      <Paragraph>
        Our goal is to help you efficiently manage and optimize your cloud resources, ensuring that you get the most out of your infrastructure investments.
      </Paragraph>
      <Paragraph>
        For more information, feel free to explore our various features and reach out to us if you have any questions or feedback.
      </Paragraph>
    </Container>
  );
}

export default About;
