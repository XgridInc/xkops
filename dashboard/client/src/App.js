import {
  Navigation,
  Home,
  UnclaimedVolumes
} from './components'
import { Route, Routes } from 'react-router-dom'

// App function which tells how to render the application like Navigation and Routes
function App () {
  return (
    <>
      <Navigation />
      <Routes>
        <Route path='/' element={<Home />} />
        <Route path='/unclaimed-volumes' element={<UnclaimedVolumes />} />
      </Routes>
    </>
  )
}

export default App
