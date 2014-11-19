var net = require("net");

var client = net.connect({path: '/tmp/dowse-notify.sock'}, onConnect);

function onConnect() {
  var data = {
    type: "dnsmasq-dhcp-script",
    dnsmasqArg: process.argv[2],
    dnsmasqEnv: filteredDnsmasqFromProcessEnv()
  };
  console.log(JSON.stringify(data));
  client.write(JSON.stringify(data));
  client.end("\r\n");
}

function filteredDnsmasqFromProcessEnv() {
  return Object.keys(process.env).reduce(function(acc, item) {
    if (item.match(/^DNSMASQ_/)) {
      acc[item] = process.env[item];
    }
    return acc;
  }, {});
}
