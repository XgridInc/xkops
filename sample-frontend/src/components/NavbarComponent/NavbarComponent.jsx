import React from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';
import Logo from '../../images/xkops_logo.png';
import { Button } from "antd";
const NavbarContainer= styled.div`
.navbar{
    position: relative;
   # border: 1px solid red;
    display: flex;
    justify-content: space-between;
    align-items: center;
    text-align: center;
    background-color: rgb(247, 247, 247);
    padding: 0 5%;
}
.logo-links{
  display: flex;
  #background-color: blue;
  align-items: center;
    }
.navbar ul li{
  list-style: none;
  display: inline-block;
  padding: 20px;
  color: 736D6D;
}
.logo{
  width:6rem;
}
.text{
   color:rgba(115,109,109,100%);
   font-size: 20px;
   list-style: none;
   text-decoration: none;
   font-weight: bold;
}
.login-button{
  color:538ACA;
}
.navbar-login{
  #background-color: red;
  display:flex;
  justify-content: space-between;
}


`
const NavbarComponent = () => {
  return (
    <NavbarContainer>

    <nav className="navbar">
      <div className="logo-links">
        <div className="navbar-logo">
          <Link to="/">
            <img src={Logo} alt="Logo" className="logo" /> {/* Update the src to your logo */}
          </Link>
        </div>
        <ul className="navbar-menu">
          <li><Link to="/" className='text'>Home</Link></li>
          <li><Link to="/workflows" className='text'>Workflows</Link></li>
          {/* <li><Link to="/recommendations" className='text'>Recommendations</Link></li> */}
          <li><Link to="/resources" className='text'>Resources</Link></li>
        </ul>
      </div>
      <div className="navbar-login">
        <Button className="login-button" type="primary" size="large" style={{background:'#538ACA'}} shape="round">Sign in</Button>
        <Button className="login-button" type="primary" size="large" style={{background:'#538ACA', marginLeft:"5%"}} shape="round">Sign up</Button>
      </div>
    </nav>
    </NavbarContainer>
  );
};

export default NavbarComponent;
