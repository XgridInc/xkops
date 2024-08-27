import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import styled from 'styled-components';
import Navbar from './Navbar';
import Home from './Home';
import About from './About';
import Contact from './Contact';
import UnclaimedVolumes from './UnclaimedVolumes'; // Import the new page

// Styled components
const Page = styled.div`
  padding: 20px;
`;

function App() {
  const links = [
    { name: 'Home', path: '/' },
    { name: 'About', path: '/about' },
    { name: 'Contact', path: '/contact' },
    { name: 'Unclaimed Volumes', path: '/unclaimed-volumes' }, // Add the new page link
  ];

  return (
    <Router>
      <Navbar links={links} />
      <Page>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="/unclaimed-volumes" element={<UnclaimedVolumes />} /> {/* Add the new route */}
        </Routes>
      </Page>
    </Router>
  );
}

export default App;
