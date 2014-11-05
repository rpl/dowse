#!/usr/bin/env dowse

#+MODULE: squid-privoxy-polipo
#+NAME: Squid -> Privoxy -> Polipo
#+DESC: Transparent http proxy pipeline chaining squid to privoxy to polipo.
#+TYPE: http proxy
#+DEPS: none
#+INSTALL: privoxy squid3 polipo
#+AUTHOR: Jaromil, Anatole
#+VERSION: 0.1

require squid3
require privoxy
require polipo

# setup a transparent proxy on port 80
# using squid, privoxy and polipo

module_setup() {

    squid_conf > $DIR/run/squid.conf
    cat <<EOF >> $DIR/run/squid.conf
cache_peer $dowse parent 8118 0 default no-query no-digest no-netdb-exchange proxy-only
pid_filename $DIR/run/squid.pid
EOF

    privoxy_conf > $DIR/run/privoxy.conf
    cat <<EOF >> $DIR/run/privoxy.conf
# pass through polipo
forward / $dowse:8123
EOF

    polipo_conf > $DIR/run/polipo.conf
    cat <<EOF >> $DIR/run/polipo.conf
logFile = $DIR/log/polipo.log
EOF

}

module_start() {
    func "setup transparent proxy to squid -> privoxy -> polipo"
    iptables -t nat -A PREROUTING -i $interface -s $dowsenet \
        -p tcp --dport 80 -j REDIRECT --to-port 3128

    polipo_start $DIR/run/polipo.conf $DIR/run/polipo.pid

    privoxy_start $DIR/run/privoxy.conf $DIR/run/privoxy.pid

    squid_start $DIR/run/squid.conf $DIR/run/squid.pid
}

module_stop() {
    squid_stop $DIR/run/squid.pid

    privoxy_stop $DIR/run/privoxy.pid

    polipo_stop $DIR/run/polipo.pid
}
