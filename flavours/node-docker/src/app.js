const http = require('http');

function createServer() {
  // TLS is terminated by the reverse proxy in front of the container, so plain HTTP is intended here.
  // nosemgrep: problem-based-packs.insecure-transport.js-node.using-http-server.using-http-server
  return http.createServer((req, res) => {
    if (req.url === '/health') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'ok' }));
    } else {
      res.writeHead(200, { 'Content-Type': 'text/plain' });
      res.end('Hello from repo-template!\n');
    }
  });
}

if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  createServer().listen(PORT, () => console.log(`App running on port ${PORT}`));
}

module.exports = { createServer };
