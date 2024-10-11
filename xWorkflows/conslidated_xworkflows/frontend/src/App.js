import './App.css';
import { Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';
import NavbarComponent from './components/NavbarComponent/NavbarComponent';
import WorkflowsPage from './pages/WorkflowsPage';
import ResourcePage from './pages/ResourcePage';
import UnclaimedPvPage from './pages/WorkloadPages/UnclaimedPvPage';
import AbandonendWorkloadPage from './pages/WorkloadPages/AbandonendWorkloadPage';
import RightSizeContainerPage from './pages/WorkloadPages/RightSizeContainerPage';
import UnderutilizedNodesPage from './pages/WorkloadPages/UnderutilizedNodesPage';

function App() {
  return (
    <div className="App">
      <NavbarComponent />
      <main>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/workflows" element={<WorkflowsPage />} />
          <Route path="/resources" element={<ResourcePage />} />
          <Route path="/unclaimedpvs" element={<UnclaimedPvPage />} />
          <Route path="/underutilizednodes" element={<UnderutilizedNodesPage />} />
          <Route path="/rightsizecontainer" element={<RightSizeContainerPage />} />
          <Route path="/abandonendworkload" element={<AbandonendWorkloadPage />} />
        </Routes>
      </main>
    </div>
  );
}

export default App;

