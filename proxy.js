const http = require('http');

const TARGET_HOST = '127.0.0.1';
const TARGET_PORT = 4096;
const PROXY_PORT = 10000;

const server = http.createServer((req, res) => {
  if (req.url === '/ping') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', message: 'Pong! OpenCode is awake.' }));
    return;
  }

  const proxyReq = http.request({
    host: TARGET_HOST,
    port: TARGET_PORT,
    path: req.url,
    method: req.method,
    headers: req.headers
  }, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res, { end: true });
  });

  proxyReq.on('error', (err) => {
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end('Bad Gateway: OpenCode server is booting or unreachable.');
  });

  req.pipe(proxyReq, { end: true });
});

console.log(`Native Proxy running on port ${PROXY_PORT}...`);
server.listen(PROXY_PORT, '0.0.0.0');
