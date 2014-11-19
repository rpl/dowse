var emitStream = require("emit-stream");
var es = require("event-stream");
var dowseEvents = require("./notify-sock-server").events;

dowseEvents.on("dnsmasq-dhcp-script", function(data) {
  console.log("DHCP SCRIPT", data);
});

module.exports = function onEvents() {
    // set timeout as high as possible
    this.req.socket.setTimeout(Infinity);

    // send headers for event-stream connection
    // see spec for more information
    this.res.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive'
    });
    this.res.write('\n');

    emitStream(dowseEvents)
      .pipe(es.mapSync(function (evt) {
         var type = evt[0], data = evt[1];
         var event = 'event: ' + type + '\n' +
                 'id: ' + (new Date()).getMilliseconds() + '\n' +
                 'data: ' + JSON.stringify(data) + '\n\n';

         console.log("SERVER SENT EVENT", event);
         return event;
      }))
      .pipe(this.res);

    // When the request is closed, e.g. the browser window
    // is closed. We search through the open connections
    // array and remove this connection.
    this.req.once("close", function() {
      console.log("SERVER SENT EVENTS SOCKET CLOSED");
    });
};
