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

const express = require('express')
const request = require('request')
const path = require('path')
const app = express()
const allowCrossDomain = function (req, res, next) {
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Headers', 'Content-Type')
  next()
}

// Allow cross-origin requests
app.use(allowCrossDomain)
// Parse incoming JSON data
app.use(express.json())
// Serve static files from the 'build' directory
app.use(express.static('build'))

// Sends a GET request to retrieve information about all persistent volumes from a Kubernetes cluster using the Kubecost API.
app.get('/allPersistentVolumes', (req, res) => {
  const options = {
    url: 'http://kubecost-cost-analyzer.kubecost.svc.cluster.local:9003/allPersistentVolumes',
    headers: {
      'User-Agent': 'request',
      Accept: 'application/json'
    }
  }

  handleRequest(req, res, options, 'get')
  // request.get(options, (error, response, body) => {
  //   if (error) {
  //     console.error(error)
  //     res.status(500).send(JSON.stringify(error))
  //   } else {
  //     console.log(response.statusCode)
  //     res.status(response.statusCode).send(body)
  //   }
  // })
})

// Sends a POST request to trigger a Robusta test run using the Robusta Runner API with the
// request body containing the test configuration in JSON format.
app.post('/robusta', async (req, res) => {
  const options = {
    url: 'http://robusta-runner.robusta.svc.cluster.local/api/trigger',
    headers: {
      'Content-Type': 'application/json'
    },
    json: req.body
  }

  handleRequest(req, res, options, 'post')
  // request.post(options, (error, response, body) => {
  //   if (error) {
  //     console.error(error)
  //     res.status(500).send(JSON.stringify(error))
  //   } else {
  //     console.log(response.statusCode)
  //     res.status(response.statusCode).send(body)
  //   }
  // })
})

// This function takes in the request, response, options,
// and method as parameters and makes an HTTP request using the request library.
// It handles errors and sends the response back to the client.
function handleRequest (req, res, options, method) {
  request[method](options, (error, response, body) => {
    if (error) {
      console.error(error)
      res.status(500).send(JSON.stringify(error))
    } else {
      console.log(response.statusCode)
      res.status(response.statusCode).send(body)
    }
  })
}

// Serves the React app by sending the index.html file in the 'build' directory for all GET requests that don't match any other routes.
app.get('/*', function (req, res) {
  res.sendFile(path.join(__dirname, '/build/index.html'))
})

// Start the server
app.listen(3000, () => {
  console.log('Server listening on port 3000')
})
