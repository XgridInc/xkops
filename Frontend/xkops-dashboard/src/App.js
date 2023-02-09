import {
  Navigation,
  Footer,
  Home,
  Abandoned_Workloads,
  Unclaimed_Volumes,
} from "./components";
import { Route, Routes } from "react-router-dom";

function App() {
  return (
    <>
      <Navigation />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/unclaimed-volumes" element={<Unclaimed_Volumes />} />
        <Route path="/abandoned-workloads" element={<Abandoned_Workloads />} />
      </Routes>
      <Footer />
    </>
  );
}

export default App;
