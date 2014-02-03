var app = require('./app.js')();
var server = require('http').createServer(app);

server.listen(process.env.PORT, process.env.IP);
