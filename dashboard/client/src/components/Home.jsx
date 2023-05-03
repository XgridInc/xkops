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

function Home () {
  return (
    <div className='home'>
      <div class='container'>
        <div class='row align-items-center my-5'>
          <div class='col-lg-7'>
            <img
              class='img-fluid rounded mb-4 mb-lg-0'
              src='http://placehold.it/900x400'
              alt=''
            />
          </div>
          <div class='col-lg-5'>
            <h1 class='font-weight-light'>Home</h1>
            <p>
              XkOps is a platform for Kubernetes Risk Detection and Mitigation.
              It aims to help users identify potential security risks and observability gaps in their Kubernetes
              clusters by detecting the presence of certain tools and configurations.
              By providing information about the risk level and observability associated with these tools,
              as well as associated costs, this platform hopes to empower users to make informed decisions about how to mitigate those risks, improve their observability
              and optimize their clusters for cost efficiency.
              Additionally, the project includes features to help users install recommended tools and configurations in order to decrease the risk level of their cluster,
              enhance their visibility and also optimizating their cost usage. Whether you're new to Kubernetes or an experienced user, we hope this project will be a useful resource for managing the security, observability and cost efficiency of your clusters.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Home
