# What is ssl-proxy

ssl-proxy terminates a HTTPS connection for a linked dockers unencrypted web service. If you bind both ssl-proxy ports, 80 and 443 to the host, port 80 will redirect all requests to port 443. 

## ssl-proxy Docker image tags

* `ssl-proxy:1.0`, `ssl-proxy:latest`

    Basic customizable SSL proxy based on `debian:jessie` and jessies version of Apache. Proxying port 80 is supported in this version.

## Usage

    docker run --name my-container-name --port 80:80 --port 443:443 --volume ./mycerts:/etc/ssl/private --environment SERVER_NAME=www.mydomain.com --link container-to-proxy:http -d ssl-proxy:latest

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

* Private key file is `$SERVER_NAME.key`
* Public certificate is `$SERVER_NAME.cert`
* Certificate chain is `$SERVER_NAME.chain`

Get the certificate chain from your CA if you don't have it at hand.

## Limits/caveats 

* Proxies only port 80 from linked container at the moment
* Port 80 will always redirect to 443, not configurable at the moment

###### vim: set syn=markdown spell spl=en: