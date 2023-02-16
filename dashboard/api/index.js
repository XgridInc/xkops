const express = require('express');
const k8s = require('@kubernetes/client-node');
const request = require('request');

const app = express();

app.use(express.json())
app.use(express.static('build'));

app.get('/*', function (req, res) {
  res.sendFile(__dirname + '/build/index.html');
});

// Handle POST requests
app.post('/robusta', async (req, res) => {
  const options = {
    url: 'http://robusta-runner.robusta.svc.cluster.local/api/trigger',
    headers: {
      'Content-Type': 'application/json'
    },
    json: req.body
  };

  request.post(options, (error, response, body) => {
    if (error) {
      console.error(error);
      res.status(500).send(JSON.stringify(error));
    } else {
      console.log(response.statusCode);
      res.status(response.statusCode).send(body);
    }
  });

});

// Start the server
app.listen(3000, () => {
  console.log('Server listening on port 3000');
});

 // const response = await api.listNamespacedPod('default');
  // extract the names of the pods from the response
  // const podNames = response.body.items.map(pod => pod.metadata.name);

    // res.send("Hello World")
  // res.json({ requestBody: JSON.stringify(podNames) })

   // res.json({ requestBody: JSON.stringify(req.body) })


   
  // const kc = new k8s.KubeConfig();
  // kc.loadFromCluster();

  // const api = kc.makeApiClient(k8s.CoreV1Api);

  // const requestOptions = {
  //   url: 'http://robusta-runner.robusta.svc.cluster.local/api/trigger',
  //   method: 'POST',
  //   headers: {
  //     'Content-Type': 'application/json'
  //   },
  //   body: JSON.stringify(req.body)
  // };


  // try {
  //   await api.connectPostNamespacedServiceProxy(
  //     'robusta-runner', // Service name
  //     'robusta', // Service namespace
  //     '', // Service port (leave empty if only one port)
  //     true, // Use TLS
  //     requestOptions // Request options
  //   );
  //   res.send('Request sent to service');
  // } catch (error) {
  //   console.error(error);
  //   res.status(500).send(JSON.stringify(error));
  // }

  // api.connectPostNamespacedServiceProxy(
  //   'robusta-runner', // Service name
  //   'robusta', // Service namespace
  //   '/api/trigger', // Service endpoint
  //   '', // Pod name (optional)
  //   '', // Pod namespace (optional)
  //   req, // Incoming request
  //   res, // Outgoing response
  // );