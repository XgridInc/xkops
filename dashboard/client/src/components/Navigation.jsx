// Copyright (c) 2023, Xgrid Inc, https://xgrid.co

// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import React from 'react'
import { NavLink } from 'react-router-dom'

// Renders a navigation bar with links to the home page and a page displaying unclaimed volumes using the NavLink component from React Router.
function Navigation () {
  return (
    <div className='navigation'>
      <nav className='navbar navbar-expand navbar-dark bg-dark'>
        <div className='container'>
          <NavLink className='navbar-brand' to='/'>
            XkOps Dashboard
          </NavLink>
          <div>
            <ul className='navbar-nav ml-auto'>
              <li className='nav-item'>
                <NavLink className='nav-link' to='/'>
                  Home
                  <span className='sr-only'>(current)</span>
                </NavLink>
              </li>
              <li className='nav-item'>
                <NavLink className='nav-link' to='/unclaimed-volumes'>
                  Unclaimed Volumes
                </NavLink>
              </li>
              <li className='nav-item' />
            </ul>
          </div>
        </div>
      </nav>
    </div>
  )
}

export default Navigation
