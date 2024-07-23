const http = require("http");
const PORT = 2024;

const server = http.createServer((req, res) => {

    let body = "";

    req.on("data", (chunk) => {
        body += chunk;
    });

    req.on("end", () => {
        console.log("[+] Active: ", body);
        res.end("ACK");
    });

    if(req.method == "GET") {
        res.end("ACK");
    }
});

server.listen(PORT, (e) => {
    console.log("[+] Server started on PORT: ", PORT);
});