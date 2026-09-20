const http = require('http');
const httpProxy = require('http-proxy');


const proxy = httpProxy.createProxyServer({});

const server = http.createServer((req, res) => {
  if (req.url === '/ping') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', message: 'Pong! OpenCode is awake.' }));
    return;
  }

  proxy.web(req, res, { target: 'http://127.0.0.1:4096' }, (err) => {
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end('Bad Gateway: OpenCode server is starting up or unreachable.');
  });
});

console.log('Smart Proxy running on port 10000...');
server.listen(10000, '0.0.0.0');
