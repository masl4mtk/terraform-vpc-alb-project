const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = process.env.PORT || 80;
const PUBLIC_DIR = path.join(__dirname, "public");

const MIME_TYPES = {
  ".html": "text/html",
  ".css": "text/css",
  ".js": "text/javascript",
};

const server = http.createServer((req, res) => {
  const filePath =
    req.url === "/" ? path.join(PUBLIC_DIR, "index.html") : path.join(PUBLIC_DIR, req.url);

  const ext = path.extname(filePath);
  const contentType = MIME_TYPES[ext] || "application/octet-stream";

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain" });
      res.end("404 Not Found");
      return;
    }
    res.writeHead(200, { "Content-Type": contentType });
    res.end(content);
  });
});

server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
