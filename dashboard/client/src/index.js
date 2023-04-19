//  Copyright (c) 2023, Xgrid Inc, https://xgrid.co

//  Licensed under the Apache License, Version 2.0 (the 'License');
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at

//  http://www.apache.org/licenses/LICENSE-2.0

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an 'AS IS' BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import React from 'react'
// Importing the ReactDOM library to render the React app.
import ReactDOM from 'react-dom/client'
// Importing the stylesheet for the app.
import './index.css'
import App from './App'
// Importing the BrowserRouter component from the react-router-dom library, which enables client-side routing.
import { BrowserRouter } from 'react-router-dom'

// Create a React root at the specified DOM element with an ID of 'root'.
const root = ReactDOM.createRoot(document.getElementById('root'))

// Render the App component within the BrowserRouter component to the root element.
root.render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
)
