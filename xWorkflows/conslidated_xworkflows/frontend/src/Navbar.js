import React from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

// Styled components
const Nav = styled.nav`
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #0038A8; /* Dark blue similar to Kubernetes */
  padding: 10px 20px;
  color: white;
`;

const NavLinks = styled.div`
  display: flex;
  gap: 20px;
`;

const NavLink = styled(Link)`
  color: white;
  text-decoration: none;
  font-size: 18px;
  
  &:hover {
    text-decoration: underline;
    color: #B0C4DE; /* Light steel blue for hover effect */
  }
`;

const Title = styled.h1`
  margin: 0;
  font-size: 24px;
  font-weight: bold;
  color: #E9F0F5; /* Light blue for the title */
`;

const Navbar = () => {
  return (
    <Nav>
      <Title>XkOps</Title>
      <NavLinks>
        <NavLink to="/">Home</NavLink>
        <NavLink to="/unclaimed-volumes">Unclaimed Volumes</NavLink>
        <NavLink to="/about">About</NavLink>
        <NavLink to="/contact">Contact</NavLink>
      </NavLinks>
    </Nav>
  );
};

export default Navbar;
