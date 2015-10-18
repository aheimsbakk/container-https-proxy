# What is ssl-proxy

ssl-proxy terminates a HTTPS connection for a linked dockers unencrypted web service. If you bind both ssl-proxy ports, 80 and 443 to the host, port 80 will redirect all requests to port 443. 

## Tagso

* `2.0`, `latest`

    Apache header hardening with the following.

        Header set X-Content-Type-Options "nosniff"
        Header set X-XSS-Protection "1; mode=block"
        Header set X-Robots-Tag "none"
        Header set X-Frame-Options "SAMEORIGIN"

* `1.1`

    Added ProxyPreserveHost to config. 

* `1.0.1`

    Updated documentation for docker. 

* `1.0`

    Basic customizable SSL proxy based on `debian:jessie` and jessies version of Apache. Proxying port 80 is supported in this version.

## Start ssl-proxy

    docker run --name my_proxy -p 80:80 -p 443:443 -v ./my_certs:/etc/ssl/private -e SERVER_NAME=www.mydomain.com --link www_container:http -d ssl-proxy:latest

### Environment variables

* `SERVER_NAME` - your full server name - FQDN

    default: `localhost`

* `SERVER_ADMIN` - your webmaster email 

    default `webmaster@${SERVER_NAME}`

* `SSL_CIPHERS` - your preferred SSL ciphers

    default: `EECDH:EDH:AES:!aNULL:!eNULL:!LOW:!RC4:!3DES:!DES:!MD5:!EXP:!PSK:!SRP:!DSS`

* `SSL_STRICT_TRANSPORT` - strict transport options

    default: `max-age=31536000; includeSubDomains`

### Volumes

* `/etc/ssl/private` - where certificate resides

### Certificate naming

In `/etc/ssl/private` certificate filename is important to make Apache work with your own certificate. 

* Private key file is `${SERVER_NAME}.key`
* Public certificate is `${SERVER_NAME}.cert`
* Certificate chain is `${SERVER_NAME}.chain`

Get the certificate chain from your CA if you don't have it at hand.

## Limits/caveats 

* Proxies only port 80 from linked container at the moment
* Port 80 will always redirect to 443, not configurable at the moment

###### vim: set syn=markdown spell spl=en:
