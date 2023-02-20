import express, { json as _json, static as _static} from 'express';
import { post } from 'request';

const app = express();

app.use(_json())
app.use(_static('build'));

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

  post(options, (error, response, body) => {
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

