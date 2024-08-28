/* eslint-disable */
const express = require('express');
const fetch = require('node-fetch');
const app = express();
const cors = require('cors');
const bodyParser = require('body-parser');
/* eslint-enable */

// create application/json parser
const jsonParser = bodyParser.json();
app.use(
  cors({
    origin: ['http://localhost:8080'],
    methods: ['*'],
  }),
);

const port = process.env.port || 3010;

app.use(express.static('build'));

app.get('/', (req, res) => {
  res.sendFile(`${__dirname}/build/index.html`);
});

app.post('/v1/sessions/', jsonParser, (req, res) => {
  /* eslint-disable no-console */
  console.log('POST /v1/jobs/', new Date().toTimeString(), req.body);
  res.statusCode = 201;
  res.send(JSON.stringify(req.body));
});

app.get('/v1/verdicts/', (req, res) => {
  /* eslint-disable no-console */
  console.log('/v1/verdicts/', new Date().toTimeString());
  let toSend;

  fetch('http://localhost:55654/v1/verdicts')
    .then(response => {
      if (!response.ok) {
        console.log('response not okay');
        throw Promise.reject(response.status);
      }
      toSend = response;
    })
    .catch(error => {
      console.log(error);
    });
  console.log(`about to send${  toSend}`);
  res.send(toSend);
});

app.listen(port, () => {
  /* eslint-disable-next-line */
  console.log(
    `MF Service - "E-UI SDK Skeleton" is running on port http://localhost:${port}`,
  );
});
