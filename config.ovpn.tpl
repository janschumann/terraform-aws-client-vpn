client
dev tun
proto tcp
remote ${endpoint} 443
remote-random-hostname
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
verb 3
key path-to-key-from-${client_cert_arn}
cert path-to-cert-from-${client_cert_arn}
${routes}
<ca>
${ca_cert}
</ca>


reneg-sec 0
