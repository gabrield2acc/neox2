// Minimal realm probe server (Node.js, no external deps)
// - Returns realm as plain text at /realm
// - Returns JSON { "realm": "..." } at /realm.json
// Configuration via env:
//   REALM (default: "sony.net")
//   PORT  (default: 3000)

const http = require('http');

const REALM = process.env.REALM || 'sony.net';
const PORT = parseInt(process.env.PORT || '3000', 10);

const server = http.createServer((req, res) => {
  if (req.url === '/realm') {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end(REALM + '\n');
    return;
  }

  if (req.url === '/realm.json') {
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ realm: REALM }));
    return;
  }

  // Health check / root
  if (req.url === '/' || req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('ok\n');
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
  res.end('not found\n');
});

server.listen(PORT, () => {
  console.log(`realm probe listening on :${PORT} (realm=${REALM})`);
});

