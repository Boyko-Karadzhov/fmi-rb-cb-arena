var express = require('express.io'),
	path = require('path');

var app = express();
app.http().io();

var clientPath = path.resolve('client\\');
app.use(express.static(clientPath));
app.get('/', function(req, res) {
	res.sendfile(clientPath + 'index.html');
});

/*
TODO: Add routes here
app.io.route(routePattern, function (req) {
  controller[action](req);
});
*/

console.log('Cows & Bulls Arena: Listening at 7076...');
app.listen(7076);