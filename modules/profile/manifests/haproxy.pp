class profile::haproxy (
) {

  include ::haproxy

  haproxy::frontend { 'https-httpfs':
    ipaddress     => $::ipaddress,
    ports         => '15000',
    mode          => 'tcp',
    bind_options  => 'accept-proxy',
    options       => [
      { 'default_backend' => 'static' },
      { 'timeout client'  => '30s' },
      { 'option'          => [
          'tcplog',
          'accept-invalid-http-request',
        ],
      }
    ],
  }  

}



# frontend www-https 
# bind 10.10.70.62:14001 ssl crt /opt/mapr/conf/haproxy.pem 
# mode http 
# default_backend static 
# 
# backend static 
# mode http 
# balance roundrobin 
# server static 127.0.0.1:14000 check 