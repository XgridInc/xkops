import React from 'react'
//Importing the ReactDOM library to render the React app.
import ReactDOM from 'react-dom/client'
//Importing the stylesheet for the app.
import './index.css'
import App from './App'
//Importing the BrowserRouter component from the react-router-dom library, which enables client-side routing.
import { BrowserRouter } from 'react-router-dom'

//Create a React root at the specified DOM element with an ID of 'root'.
const root = ReactDOM.createRoot(document.getElementById('root'))

//Render the App component within the BrowserRouter component to the root element.
root.render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
)
