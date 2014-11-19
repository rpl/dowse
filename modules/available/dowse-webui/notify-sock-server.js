var net = require('net');
var through = require("through");
var es = require('event-stream');
var events = require('events');

// create sock server connection handler
var server = net.createServer(function(conn) {
  conn.pipe(es.split())
      .pipe(es.parse())
      .pipe(through(emitDowseEvents));
});

// expose service listen method
exports.listen = server.listen.bind(server);

// expose event emitter api
exports.events = new events.EventEmitter();

// private helper (emit events from piped json stream)
function emitDowseEvents(data) {
  if (data && (typeof data.type == "string") &&
      data.type.length > 0) {
     exports.events.emit(data.type, data);
  }
}
