require("./notify-sock-server").listen('/tmp/dowse-notify.sock', function() {
  console.log("LISTENING ON /tmp/dowse-notify.sock");
});

require("./http-server").listen(4000, function() {
  console.log('Dowse WebUI PID ', process.pid, ' listening on http://localhost:' +
              this.address().port);
});
