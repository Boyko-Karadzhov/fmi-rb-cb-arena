var express = require('express.io'),
  faye = require('faye'),
	path = require('path');

var app = express();
app.http().io();

var clientPath = path.resolve('lib\\cows_bulls_arena\\js-client\\');
app.use(express.static(clientPath));
app.get('/', function(req, res) {
	res.sendfile(clientPath + '\\index.html');
});

var client = new faye.Client('http://localhost:3000/faye');

client.connect();

client.on('transport:down', function() {
  console.log('the client is offline');
});

client.on('transport:up', function() {
  console.log('the client is online');
});

setInterval(function () {
client.publish('/foo2', {
  text: 'publishing from node'
});
}, 2000);


client.subscribe('/foo', function (message) {
  console.log('happy ' + message);
});


/*
TODO: Add routes here
app.io.route(routePattern, function (req) {
  controller[action](req);
});
*/

console.log('Cows & Bulls Arena: Listening at 7076...');
app.listen(7076);