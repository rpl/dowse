#+MODULE: squid-privoxy
#+NAME: Squid -> Privoxy
#+DESC: Transparent http proxy pipeline chaining squid to privoxy
#+TYPE: http proxy
#+DEPS: none
#+INSTALL: privoxy squid3
#+AUTHOR: Jaromil, Anatole
#+VERSION: 0.1

require squid3
require privoxy

# setup a transparent proxy on port 80
# using squid and privoxy

module_setup() {

    squid_conf > $DIR/run/squid.conf
    cat <<EOF >> $DIR/run/squid.conf
# pass through privoxy
cache_peer localhost parent 8118 0 default no-query no-digest no-netdb-exchange
pid_filename $DIR/run/squid.pid
EOF

    privoxy_conf > $DIR/run/privoxy.conf
}

module_start() {
    func "setup transparent proxy to squid -> privoxy"
    iptables -t nat -A PREROUTING -i $interface -s $dowsenet \
	-p tcp --dport 80 -j REDIRECT --to-port 3128

    privoxy_start $DIR/run/privoxy.conf $DIR/run/privoxy.pid

    squid_start $DIR/run/squid.conf $DIR/run/squid.pid
}

module_stop() {
    squid_stop $DIR/run/squid.pid

    privoxy_stop $DIR/run/privoxy.pid
}
