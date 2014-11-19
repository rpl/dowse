var evtSource = new EventSource("/events");

evtSource.onmessage = function(e) {
  console.log("ON MESSAGE", e);
};

evtSource.addEventListener("dnsmasq-dhcp-script", function(e) {
  console.log("DHCP EVENT", e);
}, false);
