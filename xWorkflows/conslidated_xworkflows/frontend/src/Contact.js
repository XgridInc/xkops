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

const ContactForm = styled.form`
  display: flex;
  flex-direction: column;
  gap: 15px;
`;

const Input = styled.input`
  padding: 10px;
  font-size: 16px;
  border: 1px solid #ddd;
  border-radius: 4px;
`;

const TextArea = styled.textarea`
  padding: 10px;
  font-size: 16px;
  border: 1px solid #ddd;
  border-radius: 4px;
  resize: vertical;
`;

const Button = styled.button`
  padding: 10px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;

  &:hover {
    background-color: #45a049;
  }
`;

const Contact = () => {
  return (
    <Container>
      <Title>Contact Us</Title>
      <Paragraph>
        If you have any questions or need support, please fill out the form below. We will get back to you as soon as possible.
      </Paragraph>
      <ContactForm>
        <Input type="text" placeholder="Your Name" required />
        <Input type="email" placeholder="Your Email" required />
        <TextArea rows="5" placeholder="Your Message" required></TextArea>
        <Button type="submit">Send Message</Button>
      </ContactForm>
    </Container>
  );
}

export default Contact;
