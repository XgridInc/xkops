import {
  Navigation,
  Home,
  AbandonedWorkloads,
  UnclaimedVolumes
} from './components'
import { Route, Routes } from 'react-router-dom'

function App () {
  return (
    <>
      <Navigation />
      <Routes>
        <Route path='/' element={<Home />} />
        <Route path='/unclaimed-volumes' element={<UnclaimedVolumes />} />
        <Route path='/abandoned-workloads' element={<AbandonedWorkloads />} />
      </Routes>
    </>
  )
}

export default App
