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

var sockets = {};
['sign-in', 'lobby-game-list', 'sign-out', 'new-game', 'join', 'game-details', 'leave', 'ask'].forEach(function (value) {
  app.io.route(value, function (req) {
    sockets[req.socket.id] = req.io;
    client.publish('/server', {
      action: value,
      socketId: req.socket.id,
      data: req.data
    });
  });
});

client.subscribe('/client', function (message) {
  if (message.target !== '*') {
    sockets[message.target].emit(message.action, message.data);
  }
  else {
    Object.keys(sockets).forEach(function (val) {
      if (sockets[val].connected()) {
        sockets[val].emit(message.action, message.data);
      }
    });
  }
});

client.connect();

console.log('Cows & Bulls Arena: Listening at 7076...');
app.listen(7076);