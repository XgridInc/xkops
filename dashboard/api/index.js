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

app.use(allowCrossDomain)
app.use(express.json())
app.use(express.static('build'))

app.get('/*', function (req, res) {
  res.sendFile(path.join(__dirname, '/build/index.html'))
})

// Handle POST requests
app.post('/robusta', async (req, res) => {
  const options = {
    url: 'http://robusta-runner.robusta.svc.cluster.local/api/trigger',
    headers: {
      'Content-Type': 'application/json'
    },
    json: req.body
  }

  request.post(options, (error, response, body) => {
    if (error) {
      console.error(error)
      res.status(500).send(JSON.stringify(error))
    } else {
      console.log(response.statusCode)
      res.status(response.statusCode).send(body)
    }
  })
})

// Handle GET requests
app.get('/allPersistentVolumes', async (req, res) => {
  const options = {
    url: 'http://kubecost-cost-analyzer.kubecost.svc.cluster.local:9003/allPersistentVolumes'
  }

  request.get(options, (error, response, body) => {
    if (error) {
      console.error(error)
      res.status(500).send(JSON.stringify(error))
    } else {
      console.log(response.statusCode)
      res.status(response.statusCode).send(body)
    }
  })
})

// Start the server
app.listen(3000, () => {
  console.log('Server listening on port 3000')
})
