const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const { createServer } = require('../src/app');

function request(server, path) {
  return new Promise((resolve, reject) => {
    server.listen(0, () => {
      const { port } = server.address();
      http
        .get(`http://localhost:${port}${path}`, (res) => {
          let body = '';
          res.on('data', (chunk) => (body += chunk));
          res.on('end', () => {
            server.close();
            resolve({ statusCode: res.statusCode, body });
          });
        })
        .on('error', reject);
    });
  });
}

test('GET /health returns 200 with status ok', async () => {
  const res = await request(createServer(), '/health');
  assert.strictEqual(res.statusCode, 200);
  assert.strictEqual(JSON.parse(res.body).status, 'ok');
});
